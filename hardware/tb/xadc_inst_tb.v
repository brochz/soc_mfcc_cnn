`timescale 1 ns / 100 ps

module tb;

parameter PERIOD = 10;
	
reg CLK;
//dont need di_in, we dont need to configure XADC just set this to 0
reg  [15:0 ] di_in;
//just set this to a constant is enough, we only need the result from @0x10 register


reg  [0 :0 ] dwe_in;
reg  [0 :0 ] reset_in;
reg  [0 :0 ] convst_in; //

wire [4 :0 ] channel_out;
wire [15:0 ] do_out;
wire [6 :0 ] daddr_in;  //get this signal from channel output

wire [0 :0 ] den_in;  

//transfer result @10h. 16 bit, the high 12 bits is what we need

/*
conversion phase is 22 ADCCLK cycles long. 16 DCLK cycles after BUSY goes Low, EOC
pulses High for one DCLK cycle when the conversion results have been transferred to the
output registers. 
*/

xadc_n0_50m your_instance_name (
  .di_in(di_in),              // input wire [15 : 0] di_in
  .daddr_in(daddr_in),        // input wire [6 : 0] daddr_in
  .den_in(den_in),            // input wire den_in
  .dwe_in(dwe_in),            // input wire dwe_in
  .drdy_out(drdy_out),        // output wire drdy_out
  .do_out(do_out),            // output wire [15 : 0] do_out
  .dclk_in(dclk_in),          // input wire dclk_in
  .reset_in(reset_in),        // input wire reset_in
  .convst_in(convst_in),      // input wire convst_in
  .vp_in(vp_in),              // input wire vp_in
  .vn_in(vn_in),              // input wire vn_in
  .vauxp0(vauxp0),            // input wire vauxp0
  .vauxn0(vauxn0),            // input wire vauxn0
  .channel_out(channel_out),  // output wire [4 : 0] channel_out
  .eoc_out(eoc_out),          // output wire eoc_out
  .alarm_out(alarm_out),      // output wire alarm_out
  .eos_out(eos_out),          // output wire eos_out
  .busy_out(busy_out)        // output wire busy_out
);


//clk 
assign dclk_in = CLK;
always begin
  CLK = 1'b0;
  #(PERIOD/2) CLK = 1'b1;
  #(PERIOD/2);
end

assign vp_in = 1'b0;
assign vn_in = 1'b0;
// Stimulus for Channels is applied from the SIM_MONITOR_FILE
assign vauxp0 = 1'b0;
assign vauxn0 = 1'b0;
//actuall we can use fix daddr_in 馃槀
assign daddr_in = {2'b0, channel_out};
// EOC as a DEN (enable) for the DRP, and using DRDY as a WE (write enable) for the block RAM
assign den_in = eoc_out;

//*
//initial the device 
initial begin
  di_in     = 16'h0000;
  dwe_in    = 01'b0   ;
  reset_in  = 01'b1   ;
  convst_in = 01'b0   ;

  #100;
  @(posedge dclk_in) begin
    reset_in = 01'b0;
  end 
end


// //>>>>>>>>>>>PAT1: <<<<<<<<<<<<<<<<<<<<
// //start one convert
// initial begin
// wait(~reset_in);
// wait(~busy_out);

// #(PERIOD*4);//wait some time before conversion
// //start conversion again
// @(posedge dclk_in) begin
// convst_in = ~convst_in;
// end
// //dessert the convst_in
// @(posedge dclk_in) begin
// convst_in = ~convst_in;
// end
// wait(eoc_out);
// #1000;
// end


//>>>>>>>>>>>PAT2: continual conversion<<<<<<<<<<<<<<<<<<<<

always @(negedge busy_out) begin
  #(PERIOD*4);//wait some time before conversion
  //start conversion again
  @(posedge dclk_in) begin
    convst_in = ~convst_in;
  end
  //dessert the convst_in
  @(posedge dclk_in) begin
    convst_in = ~convst_in;
  end

end

endmodule 

