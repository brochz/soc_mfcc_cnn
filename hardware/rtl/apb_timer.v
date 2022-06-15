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
// Purpose: Simple timer with APB interface 
// ----------------------------------------------
//
//-------------------------------------
// Programmer's model
// 0x00 RW    CTRL[3:0]   
//              [3] Timer Interrupt Enable
//              [2] Select External input as Clock
//              [1] Select External input as Enable
//              [0] Enable
// 0x04 RW    Current Value[31:0]
// 0x08 RW    Reload Value[31:0]
// 0x0C RWc   Interrupt state
//              [0] IntState, write 1 to clear
//-------------------------------------

module apb_timer (
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

  input  wire        EXTIN,   // External input

  output wire        TIMERINT   // Timer interrupt output
  );
  
  // Signals for read/write controls
  wire          ReadEnable;
  wire          WriteEnable;
  wire          WriteEnable00; // Write enable for Control register
  wire          WriteEnable04; // Write enable for Current Value register
  wire          WriteEnable08; // Write enable for Reload Value register
  wire          WriteEnable0C; // Write enable for Interrupt state register
  reg    [31:0] ReadMux;
  reg    [31:0] ReadMuxReg;

  // Signals for Control registers
  reg     [3:0] RegCTRL;
  reg    [31:0] RegCurrVal;
  reg    [31:0] RegReloadVal;
  reg    [31:0] NxtCurrVal;

  // Internal signals
  reg           ExtInSync1;  // Synchronisation registers for external input
  reg           ExtInSync2;
  reg           ExtInDelay;  // Delay register for edge detection
  wire          DecCtrl;     // Decrement control
  wire          ClkCtrl;     // Clk select result
  wire          EnCtrl;      // Enable select result
  wire          EdgeDetect;  // Edge detection
  reg           RegTimerInt; // Timer interrupt output register
  wire          NxtTimerInt;

  assign  WriteEnable08 = WriteEnable & (PADDR[7:2] == 6'b000010);
  // Start of main code
  // Read and write control signals
  assign  ReadEnable  = PSEL & (~PWRITE); // assert for whole APB read transfer
  assign  WriteEnable = PSEL & (~PENABLE) & PWRITE; // assert for 1st cycle of write transfer
  assign  WriteEnable00 = WriteEnable & (PADDR[7:2] == 6'b000000);
  assign  WriteEnable04 = WriteEnable & (PADDR[7:2] == 6'b000001);
  assign  WriteEnable08 = WriteEnable & (PADDR[7:2] == 6'b000010);
  assign  WriteEnable0C = WriteEnable & (PADDR[7:2] == 6'b000011);

  // Write operations
  // Control register
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      RegCTRL <= {4{1'b0}};
    else if (WriteEnable00)
      RegCTRL <= PWDATA[3:0];
  end

  // Current Value register
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      RegCurrVal <= {32{1'b0}};
    else 
      RegCurrVal <= NxtCurrVal;
  end
  
  // Reload Value register
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      RegReloadVal <= {32{1'b0}};
    else if (WriteEnable08)
      RegReloadVal <= PWDATA[31:0];
  end

// Read operation
  always @(PADDR or RegCTRL or RegCurrVal or RegReloadVal or RegTimerInt)
  begin
  case (PADDR[7:2])
   0: ReadMux =  {{28{1'b0}}, RegCTRL};
   1: ReadMux =  RegCurrVal;
   2: ReadMux =  RegReloadVal;
   3: ReadMux =  {{31{1'b0}}, RegTimerInt};
   default : ReadMux = {32{1'b0}}; // Read as 0 if address is out of range
  endcase
  end

  // Register read data
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      ReadMuxReg <= {32{1'b0}};
    else 
      ReadMuxReg <= ReadMux;
  end

  // Output read data to APB
  assign PRDATA = (ReadEnable) ? ReadMuxReg : {32{1'b0}};
  assign PREADY  = 1'b1; // Always ready
  assign PSLVERR = 1'b0; // Always okay

  // Synchronize input and delay for edge detection
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      ExtInSync1 <= 1'b0;
      ExtInSync2 <= 1'b0;
      ExtInDelay <= 1'b0;
      end
    else 
      begin
      ExtInSync1 <= EXTIN;
      ExtInSync2 <= ExtInSync1;
      ExtInDelay <= ExtInSync2;
      end
  end

  // Edge detection
  assign EdgeDetect = ExtInSync2 & ~ExtInDelay;

  // Clock selection
  assign ClkCtrl    = RegCTRL[2] ? EdgeDetect : 1'b1;
  
  // Enable selection
  assign EnCtrl     = RegCTRL[1] ? ExtInSync2 : 1'b1;
  
  // Overall decrement control
  assign DecCtrl    = RegCTRL[0] & EnCtrl & ClkCtrl;

  // Decrement counter
  always @(WriteEnable04 or PWDATA or DecCtrl or RegCurrVal or
  RegReloadVal)
  begin
  if (WriteEnable04)
    NxtCurrVal = PWDATA[31:0];
  else if (DecCtrl)
    begin
    if (RegCurrVal == 32'h0)
      NxtCurrVal = RegReloadVal;
    else
      NxtCurrVal = RegCurrVal - 1;
    end
  else
    NxtCurrVal = RegCurrVal;
  end    

  // Interrupt generation 
  // Trigger an interrupt when decrement to 0 and interrupt enabled
  assign NxtTimerInt = (DecCtrl & RegCTRL[3] &
                       (RegCurrVal==32'h00000001));

  // Registering interrupt output
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      RegTimerInt <= 1'b0;
    else
      RegTimerInt <= NxtTimerInt|(RegTimerInt & ~(WriteEnable0C & PWDATA[0]));
  end
  
  // Connect to external
  assign TIMERINT = RegTimerInt;
  
endmodule
