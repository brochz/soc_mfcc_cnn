
module ahb_decoder_system (
  // Input and output signals
  input   wire [31:0] HADDR,
  output  wire        HSEL_RAM,
  output  wire        HSEL_APB,
  output  wire        HSEL_CM3_ADC,
  output  wire        HSEL_CM3_FFT,
  output  wire        HSEL_CM3_MAC,
  output  wire        HSEL_CM3_MAC_1,
  output  wire        HSEL_CM3_LOG,
  output  wire        HSEL_DefSlave
  );

//64k SRAM 
assign HSEL_RAM = (HADDR[31:16]==16'h2000);

//32k APB and address = 0x4000_0000 ~ 0x4000_7fff
assign HSEL_APB = (HADDR[31:16]==16'h4000) & ~HADDR[15];

//4k(12bit) cm3_adc and address = 0x4001_0000 ~ 0x4001_ffff
assign HSEL_CM3_ADC = (HADDR[31:16]==16'h4001);
//4k xxx address = 0x4002_0000 - 0x4002_ffff
assign HSEL_CM3_FFT = (HADDR[31:16]==16'h4002);

assign HSEL_CM3_MAC = (HADDR[31:16]==16'h4003);

assign HSEL_CM3_MAC_1 = (HADDR[31:16]==16'h4004);

assign HSEL_CM3_LOG  = (HADDR[31:16]==16'h4005);

// Select default slave if none of the above devices is selected
assign HSEL_DefSlave = ~(HSEL_RAM |
                         HSEL_APB |
                         HSEL_CM3_ADC|
                         HSEL_CM3_FFT|
                         HSEL_CM3_MAC | 
                         HSEL_CM3_MAC_1|
                         HSEL_CM3_LOG);

endmodule
