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
// Purpose: Simple AHB to APB bridge
// ----------------------------------------------
//
module ahb_to_apb (
  input  wire         HCLK,    // Clock
  input  wire         HRESETn, // Reset

  input  wire         HSEL,    // Device select
  input  wire  [14:0] HADDR,   // Address
  input  wire  [1:0]  HTRANS,  // Transfer control
  input  wire  [2:0]  HSIZE,   // Transfer size
  input  wire         HWRITE,  // Write control
  input  wire         HNONSEC, // Security attribute (TrustZone)
  input  wire  [6:0]  HPROT,   // Protection information
  input  wire         HREADY,  // Transfer phase done
  input  wire  [31:0] HWDATA,  // Write data

  output wire         HREADYOUT, // Device ready
  output wire  [31:0] HRDATA,    // Read data output
  output wire         HRESP,     // Device response
                                 // APB Output
  output wire  [11:0] PADDR,     // APB Address
  output wire         PENABLE,   // APB Enable
  output wire         PWRITE,    // APB Write
  output wire  [2:0]  PPROT,     // APB protection information
  output wire  [3:0]  PSTRB,     // APB byte strobe
  output wire  [31:0] PWDATA,    // APB write data
  output wire         PSEL0,     // APB Select (8 slaves)
  output wire         PSEL1,
  output wire         PSEL2,
  output wire         PSEL3,
  output wire         PSEL4,
  output wire         PSEL5,
  output wire         PSEL6,
  output wire         PSEL7,
                                  // APB Inputs
  input  wire  [31:0] PRDATA0,    // Read data for each APB slave
  input  wire  [31:0] PRDATA1,
  input  wire  [31:0] PRDATA2,
  input  wire  [31:0] PRDATA3,
  input  wire  [31:0] PRDATA4,
  input  wire  [31:0] PRDATA5,
  input  wire  [31:0] PRDATA6,
  input  wire  [31:0] PRDATA7,
  input  wire         PREADY0,    // Ready for each APB slave
  input  wire         PREADY1,
  input  wire         PREADY2,
  input  wire         PREADY3,
  input  wire         PREADY4,
  input  wire         PREADY5,
  input  wire         PREADY6,
  input  wire         PREADY7,
  input  wire         PSLVERR0,   // Error state for each APB slave
  input  wire         PSLVERR1,
  input  wire         PSLVERR2,
  input  wire         PSLVERR3,
  input  wire         PSLVERR4,
  input  wire         PSLVERR5,
  input  wire         PSLVERR6,
  input  wire         PSLVERR7
  );

  // Internal signals
  reg  [15:2]   AddrReg;    // Address sample register
  reg   [7:0]   SelReg;     // One-hot PSEL output register
  reg           WrReg;      // Write control sample register
  reg   [2:0]   StateReg;   // State for finite state machine

  wire          ApbSelect;  // APB bridge is selected
  wire          ApbTranEnd; // Transfer is completed on APB
  wire          AhbTranEnd; // Transfer is completed on AHB
  reg   [7:0]   NextPSel;   // Next state of One-hot PSEL
  reg   [2:0]   NextState;  // Next state for finite state machine
  reg  [31:0]   RDataReg;   // Read data sample register
  reg   [2:0]   PProtReg;   // Protection information
  reg   [3:0]   NxtPSTRB;   // Write byte strobe next state
  reg   [3:0]   RegPSTRB;   // Write byte strobe register
  wire  [31:0]  muxPRDATA;  // Slave multiplexer signal
  wire          muxPREADY;
  wire          muxPSLVERR;

  // Start of main code

  // Generate APB bridge select
  assign    ApbSelect = HSEL & HTRANS[1] & HREADY;
  // Generate APB transfer ended
  assign    ApbTranEnd = (StateReg==3'b010) & muxPREADY;
  // Generate AHB transfer ended
  assign    AhbTranEnd = (StateReg==3'b011) | (StateReg==3'b101);

  // Generate next state of PSEL at each AHB transfer
  always @(ApbSelect or HADDR)
  begin
  if (ApbSelect)
    begin
    case (HADDR[14:12]) // Binary to one-hot encoding for device select
    3'b000 : NextPSel = 8'b00000001;
    3'b001 : NextPSel = 8'b00000010;
    3'b010 : NextPSel = 8'b00000100;
    3'b011 : NextPSel = 8'b00001000;
    3'b100 : NextPSel = 8'b00010000;
    3'b101 : NextPSel = 8'b00100000;
    3'b110 : NextPSel = 8'b01000000;
    3'b111 : NextPSel = 8'b10000000;
    default: NextPSel = 8'b00000000;
    endcase
    end
  else
    NextPSel = 8'b00000000;    
  end

  // Registering PSEL output
  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    SelReg <= 8'h00;
  else if (HREADY|ApbTranEnd)
    SelReg <= NextPSel; // Set if bridge is selected
  end                   // Clear at end of APB transfer
  
  // Sample control signals
  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    begin
    AddrReg <= {10{1'b0}};
    WrReg   <= 1'b0;
    PProtReg<= {3{1'b0}};
    end
  else if (ApbSelect) // Only change at beginning of each APB transfer
    begin
    AddrReg <= HADDR[11:2]; // Note that lowest two bits are not used
    WrReg   <= HWRITE;
    PProtReg<= {(~HPROT[0]),HNONSEC,(HPROT[1])};
    end
  end

  // Byte write strobes
  always @(*)
  begin
    if (HSEL & HTRANS[1] & HWRITE)
      begin
      case (HSIZE[1:0])
        2'b00: // byte
          begin
          case (HADDR[1:0])
          2'b00: NxtPSTRB = 4'b0001;
          2'b01: NxtPSTRB = 4'b0010;
          2'b10: NxtPSTRB = 4'b0100;
          2'b11: NxtPSTRB = 4'b1000;
          default:NxtPSTRB = 4'bxxxx; // Should not be here.
          endcase
          end
        2'b01: // half word
          NxtPSTRB = (HADDR[1])? 4'b1100:4'b0011;
        default: // word
          NxtPSTRB = 4'b1111;
      endcase
      end
    else
      NxtPSTRB = 4'b0000;
  end		
  
  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    RegPSTRB<= {4{1'b0}};
  else if (HREADY)
    RegPSTRB<= NxtPSTRB;
  end

  // Generate next state for FSM
  always @(StateReg or muxPREADY or muxPSLVERR or ApbSelect)
  begin
  case (StateReg)
   3'b000 : NextState = {1'b0, ApbSelect}; // Change to state-1 when selected
   3'b001 : NextState = 3'b010;            // Change to state-2
   3'b010 : begin
            if (muxPREADY & muxPSLVERR) // Error received - Generate two cycle
                                  // Error response on AHB by 
              NextState = 3'b100; // Changing to state-4 and 5
            else if (muxPREADY & ~muxPSLVERR) // Okay received 
              NextState = 3'b011; // Generate okay response in state 3
            else // Slave not ready
              NextState = 3'b010; // Unchange
            end
   3'b011 : NextState = {1'b0, ApbSelect}; // Terminate transfer
                                  // Change to state-1 if selected
   3'b100 : NextState = 3'b101;   // Goto 2nd cycle of error response
   3'b101 : NextState = {1'b0, ApbSelect}; // 2nd Cycle of Error response
                                  // Change to state-1 if selected
   default : // Not used
            NextState = {1'b0, ApbSelect}; // Change to state-1 when selected
  endcase
  end

  // Registering state machine
  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    StateReg <= 3'b000;
  else
    StateReg <= NextState;
  end

  // Slave Multiplexer
  assign muxPRDATA = ({32{SelReg[0]}} & PRDATA0) |
                   ({32{SelReg[1]}} & PRDATA1) |
                   ({32{SelReg[2]}} & PRDATA2) |
                   ({32{SelReg[3]}} & PRDATA3) |
                   ({32{SelReg[4]}} & PRDATA4) |
                   ({32{SelReg[5]}} & PRDATA5) |
                   ({32{SelReg[6]}} & PRDATA6) |
                   ({32{SelReg[7]}} & PRDATA7) ;
  assign muxPREADY = (SelReg[0] & PREADY0) |
                   (SelReg[1] & PREADY1) |
                   (SelReg[2] & PREADY2) |
                   (SelReg[3] & PREADY3) |
                   (SelReg[4] & PREADY4) |
                   (SelReg[5] & PREADY5) |
                   (SelReg[6] & PREADY6) |
                   (SelReg[7] & PREADY7) ;
  assign muxPSLVERR = (SelReg[0] & PSLVERR0) |
                    (SelReg[1] & PSLVERR1) |
                    (SelReg[2] & PSLVERR2) |
                    (SelReg[3] & PSLVERR3) |
                    (SelReg[4] & PSLVERR4) |
                    (SelReg[5] & PSLVERR5) |
                    (SelReg[6] & PSLVERR6) |
                    (SelReg[7] & PSLVERR7) ;

  // Sample PRDATA
  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    RDataReg <= {32{1'b0}};
  else if (ApbTranEnd|AhbTranEnd)
    RDataReg <= muxPRDATA;
  end

  // Connect outputs to top level
  assign PADDR  = {AddrReg[15:2], 2'b00}; // from sample register
  assign PWRITE = WrReg;    // from sample register
  assign PPROT  = PProtReg; // from sample register
  assign PSTRB  = RegPSTRB;
  assign PWDATA = HWDATA;  // No need to register (HWDATA is in data phase)
  assign PSEL0  = SelReg[0]; // PSEL for each APB slave
  assign PSEL1  = SelReg[1];
  assign PSEL2  = SelReg[2];
  assign PSEL3  = SelReg[3];
  assign PSEL4  = SelReg[4];
  assign PSEL5  = SelReg[5];
  assign PSEL6  = SelReg[6];
  assign PSEL7  = SelReg[7];
  assign PENABLE= (StateReg == 3'b010); // PENABLE to all AHB slaves
  assign HREADYOUT = (StateReg == 3'b000)|(StateReg == 3'b011)|(StateReg==3'b101);
  assign HRDATA = RDataReg;
  assign HRESP  = (StateReg==3'b100)|(StateReg==3'b101);

endmodule
