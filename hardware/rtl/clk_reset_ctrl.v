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
// Purpose: Simple clock reset control for 
//          Cortex-M3 FPGA
// ----------------------------------------------
module clk_reset_ctrl(
  input  wire     CLKIN,
  input  wire     nSRSTIN,
  
  input  wire     SYSRESETREQ,
  input  wire     LOCKUPRESET,
  
  input  wire     GATEHCLK,
  input  wire     TRCENA,

  output wire     FCLK,
  output wire     HCLK,
  output wire     TRACECLKIN,
  output wire     PORESETn,
  output wire     HRESETn
  );
  
  reg  [2:0]  reg_por_sync;
  wire        w_sync_npor;
  reg  [1:0]  reg_srst_sync;
  
  // Synchroniser for external reset signal
  always @(posedge CLKIN or negedge nSRSTIN)
  begin
    if (~nSRSTIN)
      reg_por_sync <= 3'b000;
    else
      reg_por_sync <= {reg_por_sync[1:0], 1'b1};
  end
  
  // Synchronized power on reset
  assign w_sync_npor = reg_por_sync[2];

  // Synchroniser for system reset signal    
  always @(posedge CLKIN or negedge nSRSTIN)
  begin
    if (~nSRSTIN)
      reg_srst_sync <= 2'b00;
    else 
      if (SYSRESETREQ|LOCKUPRESET)
        reg_srst_sync <= 2'b00;
      else 
        reg_srst_sync <= {reg_srst_sync[0], 1'b1};
  end
  
  assign   FCLK = CLKIN;
  assign   PORESETn = w_sync_npor;
  assign   HRESETn  = reg_srst_sync[1];

  // HCLK clock gating
   BUFGCE u_hclk_clk_gate (
      .O(HCLK),   // 1-bit output: Clock output
      .CE(~GATEHCLK), // 1-bit input: Clock enable input for I0
      .I(CLKIN)    // 1-bit input: Primary clock
   );
  // TRACECLKIN clock gating
   BUFGCE u_traceclkin_clk_gate (
      .O(TRACECLKIN),   // 1-bit output: Clock output
      .CE(TRCENA), // 1-bit input: Clock enable input for I0
      .I(CLKIN)    // 1-bit input: Primary clock
   ); 
    
endmodule
