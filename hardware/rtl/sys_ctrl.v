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
// Purpose: System control functions
//          - automatic reset when in lockup state
//          - debugpowerup handshaking
// ----------------------------------------------


module sys_ctrl (
  input  wire        FCLK,
  input  wire        PORESETn,
  input  wire        CDBGPWRUPREQ,       // Debug power up request
  output wire        CDBGPWRUPACK,       // Debug power up acknowledge
  
  input  wire        LOCKUP,
  input  wire        LOCKUP_RESET_EN,
  output wire        LOCKUPRESET
  );

  reg [1:0] reg_dbgpwrup_sync;
  
  always @(posedge FCLK or negedge PORESETn)
  begin
  if (~PORESETn)
    reg_dbgpwrup_sync <= 2'b00;
  else
    reg_dbgpwrup_sync <=  {reg_dbgpwrup_sync[0], CDBGPWRUPREQ};
  end  
  
  assign CDBGPWRUPACK = reg_dbgpwrup_sync[1];

  //---------------------------------------------------
  // Request automatic reset if LOCKUP_RESET_EN is set to 1 and 
  // processor is in LOCKUP state
  assign LOCKUPRESET = LOCKUP_RESET_EN & LOCKUP;

endmodule
  
