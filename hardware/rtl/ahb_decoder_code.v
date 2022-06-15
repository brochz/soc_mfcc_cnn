// ----------------------------------------------
module ahb_decoder_code (
  // Input and output signals
  input   wire [31:0] HADDR,
  output  wire        HSEL_ROM,
  output  wire        HSEL_DefSlave
  );

assign HSEL_ROM = (HADDR[31:16]==16'h0000);
// Select default slave if none of the above devices is selected
assign HSEL_DefSlave = ~(HSEL_ROM );

endmodule
