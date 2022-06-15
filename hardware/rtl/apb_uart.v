// ----------------------------------------------
// Example code for
//
// System-on-Chip Design with Arm(R) Cortex(R)-M 
// Processors
//
// Reference Book
//          by Joseph Yiu, 2019 (first edition)
// 
// ISBN: 978-1-911531-19-7
// Arm Education Media
// https://www.armedumedia.com
//
// Disclaimer
// This example design is created for educational
// purpose only and are not validated to the same 
// quality level as Arm IP products. 
// Arm Education Media and author do not make any 
// warranties of these designs.
// ----------------------------------------------
// Purpose: Simple UART with APB interface
// ----------------------------------------------
//
//-------------------------------------
// Programmer's model
// 0x00 RW    CTRL[3:0]   TxIntEn, RxIntEn, TxEn, RxEn
//              [3] RX Interrupt Enable
//              [2] TX Interrupt Enable
//              [1] RX Enable
//              [0] TX Enable
// 0x04 RW    STAT[3:0]  
//              [3] RX buffer overrun (write 1 to clear)
//              [2] TX buffer overrun (write 1 to clear)
//              [1] RX buffer full (Read only)
//              [0] TX buffer full (Read only)
// 0x08 W     TXD[7:0]    Output Buffer Data
//      R     TX buffer full - bit[0]
// 0x0C RO    RXD[7:0]    Received Data
// 0x10 RW    BAUDDIV[19:0] Baud divider
//            (minimum value is 32)
//-------------------------------------

module apb_uart (
  input  wire        PCLK,    // Clock
  input  wire        PRESETn, // Reset
  // APB interface inputs
  input  wire        PSEL,    // Device select
  input  wire [7:2]  PADDR,   // Address
  input  wire        PENABLE, // Transfer control
  input  wire        PWRITE,  // Write control
  input  wire [31:0] PWDATA,  // Write data
  // APB interface outputs
  output wire [31:0] PRDATA,  // Read data
  output wire        PREADY,  // Device ready
  output wire        PSLVERR, // Device error response

  input  wire        RXD,     // Serial input
  output wire        TXD,     // Transmit data output
  output wire        TXEN,    // Transmit enabled
  output wire        BAUDTICK, // Baud rate (x16) Tick (for testbench)

  output wire        TXINT,   // Transmit Interrupt
  output wire        RXINT    // Receive Interrupt
  );


  // Signals for read/write controls
  wire          ReadEnable;
  wire          ReadEnable10;  // Read baud rate divider
  wire          WriteEnable;
  wire          WriteEnable00; // Write enable for Control register
  wire          WriteEnable04; // Write enable for Status register
  wire          WriteEnable08; // Write enable for TxData buffer
  wire          WriteEnable10; // Write enable for Baud rate divider
  wire          WriteEnable14; // Write enable for Interrupt clear
  reg     [7:0] ReadMux;
  reg     [7:0] ReadMuxReg;
  reg           ReadEnable10Reg; // Read enable for Baud rate divider
                               // (size optimisation)
  // Signals for Control registers
  reg     [3:0] RegCTRL;
  reg     [7:0] RegTxBuf;
  reg     [7:0] RegRxBuf;
  reg    [19:0] RegBaudDiv;

  // Internal signals
  // Baud rate divider
  reg    [15:0] RegBaudCntrI;
  wire   [15:0] NxtBaudCntrI;
  reg     [3:0] RegBaudCntrF;
  wire    [3:0] NxtBaudCntrF;
  wire    [3:0] MappedCntrF;
  reg           RegBaudTick;
  reg           BaudUpdated;
  wire          ReloadI;
  wire          ReloadF;
  wire          BaudDivEn;

  // Status
  wire    [3:0] UartStatus;
  reg           RegRxOverrun;
  wire          RxOverrun;
  reg           RegTxOverrun;
  wire          TxOverrun;
  wire          NxtRxOverrun;
  wire          NxtTxOverrun;
  // Interrupts
  reg           RegTXINT;
  wire          NxtTXINT;
  reg           RegRXINT;
  wire          NxtRXINT;

  // transmit
  reg     [3:0] TxState;    // Transmit FSM state
  reg     [3:0] NxtTxState; 
  wire          TxStateInc; // Bit pulse
  reg     [3:0] TxTickCnt;  // Transmit Tick counter
  wire    [3:0] NxtTxTickCnt;
  reg     [7:0] TxShiftBuf; // Transmit shift register
  wire    [7:0] NxtTxShiftBuf;
  reg           TxBufFull;  // TX Buffer full
  wire          NxtTxBufFull;
  reg           RegTxD;     // Tx Data
  wire          NxtTxD;
  wire          TxBufClear;
    
  // Receive data sync and filter
  reg           RxDSync1;  // Double flip-flop synchroniser
  reg           RxDSync2;  // Double flip-flop synchroniser
  reg     [2:0] RxDLPF;    // Average Low Pass Filter
  wire          RxShiftIn; // Shift Register Input

  // Receiver
  reg     [3:0] RxState;   // Receiver FSM state
  reg     [3:0] NxtRxState;
  reg     [3:0] RxTickCnt; // Receiver Tick counter
  wire    [3:0] NxtRxTickCnt;
  wire          RxStateInc;// Bit pulse
  reg     [6:0] RxShiftBuf;// Receiver shift data register
  wire    [6:0] NxtRxShiftBuf;
  reg           RxBufFull;
  wire          NxtRxBufFull;
  wire          RxBufSample;
  wire          RxDataRead;
  wire    [7:0] NxtRxBuf;

  // Start of main code
  // Read and write control signals
  assign  ReadEnable  = PSEL & (~PWRITE); // assert for whole APB read transfer
  assign  WriteEnable = PSEL & (~PENABLE) & PWRITE; // assert for 1st cycle of write transfer
  assign  WriteEnable00 = WriteEnable & (PADDR[7:2] == 6'b000000);
  assign  WriteEnable04 = WriteEnable & (PADDR[7:2] == 6'b000001);
  assign  WriteEnable08 = WriteEnable & (PADDR[7:2] == 6'b000010);
  assign  WriteEnable10 = WriteEnable & (PADDR[7:2] == 6'b000100);
  assign  WriteEnable14 = WriteEnable & (PADDR[7:2] == 6'b000101);
  assign  ReadEnable10  = PSEL & (~PWRITE) & (~PENABLE) & (PADDR[7:2] == 6'b000100);

  // Write operations
  // Control register
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      RegCTRL <= {4{1'b0}};
    else if (WriteEnable00)
      RegCTRL <= PWDATA[3:0];
  end

  // Status register
  assign NxtRxOverrun = (RegRxOverrun & ~(WriteEnable04 & PWDATA[3])) | RxOverrun;
  assign NxtTxOverrun = (RegTxOverrun & ~(WriteEnable04 & PWDATA[2])) | TxOverrun;

  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      RegRxOverrun <= 1'b0;
      RegTxOverrun <= 1'b0;
      end
    else
      begin
      RegRxOverrun <= NxtRxOverrun;
      RegTxOverrun <= NxtTxOverrun;
      end
  end

  // Transmit data register
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      RegTxBuf <= {8{1'b0}};
    else if (WriteEnable08)
      RegTxBuf <= PWDATA[7:0];
  end

  // Baud rate divider - integer
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      RegBaudDiv <= {20{1'b0}};
    else if (WriteEnable10)
      RegBaudDiv <= PWDATA[19:0];
  end

  // Read operation
  assign UartStatus = {RegRxOverrun, RegTxOverrun, RxBufFull, TxBufFull};
  
  always @(PADDR or RegCTRL or UartStatus or RegBaudDiv or
  TxBufFull or RegRxBuf or RegTXINT or RegRXINT)
  begin
  case (PADDR[7:2])
   0: ReadMux =  {{4{1'b0}}, RegCTRL};
   1: ReadMux =  {{4{1'b0}}, UartStatus};
   2: ReadMux =  {{7{1'b0}}, TxBufFull};
   3: ReadMux =  RegRxBuf;
   4: ReadMux =  RegBaudDiv[7:0];
   5: ReadMux =  {{6{1'b0}}, RegTXINT, RegRXINT};
   default : ReadMux = {8{1'b0}}; // Read as 0 if address is out of range
  endcase
  end

  // Register read data
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      ReadMuxReg      <= {8{1'b0}};
      ReadEnable10Reg <= 1'b0;
      end
    else 
      begin
      ReadMuxReg      <= ReadMux;
      ReadEnable10Reg <= ReadEnable10;
      end
  end

  // Output read data to APB
  assign PRDATA[ 7: 0] = (ReadEnable) ? ReadMuxReg : {8{1'b0}};
  assign PRDATA[19: 8] = (ReadEnable10Reg) ? RegBaudDiv[19:8] : {12{1'b0}};
  assign PRDATA[31: 20] = {12{1'b0}};
  assign PREADY  = 1'b1; // Always ready
  assign PSLVERR = 1'b0; // Always okay

  // --------------------------------------------
  // Baud rate generator
  // Baud rate generator enable
  assign BaudDivEn    = (RegCTRL[1:0] != 2'b00);
  assign MappedCntrF  = {RegBaudCntrF[0],RegBaudCntrF[1],
                         RegBaudCntrF[2],RegBaudCntrF[3]};
  // Reload Integer divider
  // when UART enabled and (RegBaudCntrF < RegBaudDiv[3:0]) 
  // then count to 1, or 
  // when UART enabled then count to 0
  assign ReloadI      = (BaudDivEn &
         (((MappedCntrF >= RegBaudDiv[3:0]) & 
	     (RegBaudCntrI[15:1] == {15{1'b0}})) |
	 (RegBaudCntrI[15:0] == {16{1'b0}})));
  // Next state for Baud rate divider
  assign NxtBaudCntrI = (BaudUpdated | ReloadI) ? RegBaudDiv[19:4] :
                        (RegBaudCntrI - {{15{1'b0}},BaudDivEn});
  assign ReloadF      = BaudDivEn & (RegBaudCntrF==4'h0) &
                        ReloadI;
  assign NxtBaudCntrF = (BaudUpdated) ? RegBaudDiv[3:0] :
                        (ReloadF)     ? 4'b1111 :
                        (RegBaudCntrF - {{3{1'b0}},ReloadI});
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      RegBaudCntrI   <= {16{1'b0}};
      RegBaudCntrF   <= {4{1'b0}};
      BaudUpdated    <= 1'b0;
      RegBaudTick    <= 1'b0;
      end
    else
      begin
      RegBaudCntrI   <= NxtBaudCntrI;
      RegBaudCntrF   <= NxtBaudCntrF;
      // Baud rate updated - to load new value to counters
      BaudUpdated    <= WriteEnable10;
      RegBaudTick    <= ReloadI;
      end
  end

  // Connect to external
  assign BAUDTICK = RegBaudTick;

  // --------------------------------------------
  // Transmit

  // Increment TickCounter
  assign NxtTxTickCnt = ((TxState==4'h1) & RegBaudTick) ? 4'h0 :
                        TxTickCnt + {{3{1'b0}},RegBaudTick}; 

  // Increment state (except Idle(0) and Wait for Tick(1))
  assign TxStateInc   = (((&TxTickCnt)|(TxState==4'h1)) & RegBaudTick);
  // Buffer full status
  assign NxtTxBufFull = (WriteEnable08) | (TxBufFull & ~TxBufClear);
  // Clear buffer full status when data is load into shift register
  assign TxBufClear   = ((TxState==4'h0) & TxBufFull) | 
                        ((TxState==4'hB) & TxBufFull & TxStateInc);
    
  // TxState machine
  // 0 = Idle, 1 =  Wait for Tick,
  // 2 = Start bit, 3 = D0 .... 10 = D7
  // 11 = Stop bit
  always @(TxState or TxBufFull or TxTickCnt or TxStateInc or RegCTRL)
  begin
  case (TxState)
    0: begin
       NxtTxState = (TxBufFull & RegCTRL[0]) ? 1 : 0;  // New data is written to buffer
       end
    1: begin  // Wait for next Tick
       NxtTxState = TxState + {3'b0,TxStateInc};
       end
    2,3,4,5,6,7,8,9,10: begin  // Start bit, D0 - D7
       NxtTxState = TxState + {3'b0,TxStateInc};
       end
    11: begin // Stop bit , goto next start bit or Idle
       NxtTxState = (TxStateInc) ? ( TxBufFull ? 4'h2:4'h0) : TxState;
       end
    default: // Illegal state
       NxtTxState = 4'h0;
  endcase
  end

  // Load/shift TX register
  assign NxtTxShiftBuf = (((TxState==4'h0) & TxBufFull) |
                          ((TxState==4'hB) & TxBufFull & 
			   TxStateInc)) ? RegTxBuf : 
                         (((TxState>4'h2) & TxStateInc) ?
			   {1'b1,TxShiftBuf[7:1]} : TxShiftBuf[7:0]);
			   
  // Data output
  assign NxtTxD = (TxState==2) ? 1'b0 : 
                  (TxState>4'h2) ? TxShiftBuf[0] : 1'b1;

  // Registering outputs
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      TxBufFull     <= 1'b0;
      TxShiftBuf    <= {8{1'b0}};
      TxState       <= {4{1'b0}};
      TxTickCnt     <= {4{1'b0}};
      RegTxD        <= 1'b1;
      end
    else
      begin
      TxBufFull     <= NxtTxBufFull;
      TxShiftBuf    <= NxtTxShiftBuf;
      TxState       <= NxtTxState;
      TxTickCnt     <= NxtTxTickCnt;
      RegTxD        <= NxtTxD;
      end
  end
  
  // Generate TX overrun error status
  assign TxOverrun = TxBufFull & ~TxBufClear & WriteEnable08;
  
  // Connect to external
  assign TXD  = RegTxD;
  assign TXEN = RegCTRL[0];

// --------------------------------------------
// Receive synchronizer and low pass filter

  // Doubling Flip-flop synchronizer
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      RxDSync1 <= 1'b1;
      RxDSync2 <= 1'b1;
      end
    else
      begin
      RxDSync1 <= RXD;
      RxDSync2 <= RxDSync1;
      end
  end
  
  // Averaging low pass filter
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      RxDLPF <= 3'b111;
    else if (RegBaudTick)
      RxDLPF <= {RxDLPF[1:0], RxDSync2};
  end     

  // Averaging values
  assign RxShiftIn = (RxDLPF[1] & RxDLPF[0]) |
                     (RxDLPF[1] & RxDLPF[2]) |
                     (RxDLPF[0] & RxDLPF[2]);

  // --------------------------------------------
  // Receive

  // Increment TickCounter
  assign NxtRxTickCnt = ((RxState==4'h0) & ~RxShiftIn) ? 4'h8 :
                        RxTickCnt + {{3{1'b0}},RegBaudTick};
  // Increment state
  assign RxStateInc   = ((&RxTickCnt) & RegBaudTick);
  // Shift register
  assign NxtRxShiftBuf= (RxStateInc) ? {RxShiftIn, RxShiftBuf[6:1]} : RxShiftBuf;
  // Buffer full status
  assign NxtRxBufFull = RxBufSample | (RxBufFull & ~RxDataRead);

  // Sample shift register when D7 is sampled
  assign RxBufSample  = ((RxState==4'h9) & RxStateInc);

  // Sample receive buffer
  assign NxtRxBuf     = (RxBufSample) ? {RxShiftIn,RxShiftBuf} : RegRxBuf;
  // Reading receive buffer (Set at 1st cycle of APB transfer 
  // because read mux is registered before output)
  assign RxDataRead   = (PSEL & ~PENABLE & (PADDR[7:2]==3) & ~PWRITE);
  // Generate RX overrun error status
  assign RxOverrun = RxBufFull & RxBufSample & ~RxDataRead;

  // RxState machine
  // 0 = Idle, 1 =  Start of Start bit detected
  // 2 = Sample Start bit, 3 = D0 .... 10 = D7
  // 11 = Stop bit
  always @(RxState or RxShiftIn or RxTickCnt or RxStateInc or RegCTRL)
  begin
  case (RxState)
    0: begin
       NxtRxState = ((~RxShiftIn) & RegCTRL[1]) ? 1 : 0;  // Wait for Start bit
       end
    1: begin  // Wait for middle of start bit
       NxtRxState = RxState + {3'b0,RxStateInc};
       end
    2,3,4,5,6,7,8,9: begin  // D0 - D7
       NxtRxState = RxState + {3'b0,RxStateInc};
       end
    10: begin // Stop bit , goto back to Idle
       NxtRxState = (RxStateInc) ? 0 : 10;
       end
    default: // Illegal state
       NxtRxState = 4'h0;
  endcase
  end

  // Registering 
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      RxBufFull     <= 1'b0;
      RxShiftBuf    <= {7{1'b0}};
      RxState       <= {4{1'b0}};
      RxTickCnt     <= {4{1'b0}};
      RegRxBuf      <= {8{1'b0}};
      end
    else
      begin
      RxBufFull     <= NxtRxBufFull;
      RxShiftBuf    <= NxtRxShiftBuf;
      RxState       <= NxtRxState;
      RxTickCnt     <= NxtRxTickCnt;
      RegRxBuf      <= NxtRxBuf;
      end
  end
  
// --------------------------------------------
// Interrupts
  assign NxtTXINT = RegCTRL[2] & TxBufFull & TxBufClear; // Falling edge of buffer full
  assign NxtRXINT = RegCTRL[3] & RxBufSample; // A new receive data is sampled
  
  // Registering outputs
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      RegTXINT <= 1'b0;
      RegRXINT <= 1'b0;
      end
    else
      begin
      RegTXINT <= NxtTXINT|(RegTXINT & ~(WriteEnable14 & PWDATA[1]));
      RegRXINT <= NxtRXINT|(RegRXINT & ~(WriteEnable14 & PWDATA[0]));
      end
  end      

  // Connect to external
  assign TXINT = RegTXINT;
  assign RXINT = RegRXINT;
  
endmodule
