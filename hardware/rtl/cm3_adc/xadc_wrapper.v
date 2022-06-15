module xadc_wrapper (
    //clk & rst
    input           hclk,
    input           rst_n,
    input           enable, //set this signal to enable the device

    //
    input           double, //set this signal to retrive data every two conversions
    input [15:0]    div,    //this signal gives the conversion frequency refer to hclk(MAX=500KHZ) 

    //analog input
    //vn to GND
    //vp max to 1000mV
    input           vp,
    input           vn,

    //
    output [23:0]   dout, //output data
    output          drdy //dout dready

);

//exit clean signal, after enable trans from high to low, clear regs
reg     enable_delay;
wire    exit_clean;

always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        enable_delay <= 1'b0;
    end else begin
        enable_delay <= enable;
    end
end
assign  exit_clean = enable_delay & ~enable;

//counter 
reg  [15:0]      counter;
wire [15:0]      counter_next;

always @(posedge hclk or negedge rst_n) begin
    if (~rst_n | exit_clean) begin
        counter <= 16'b0;
    end 
    else if(enable) begin
        counter <= counter_next;
    end
end
assign counter_next = counter==div? 16'b0: counter+16'b1;

//conversion start logic
wire   convst;
assign convst = counter_next==16'b0 & enable;


//xadc inst
wire [4 :0 ] channel_out;
wire [15:0 ] do_out;    //
wire [6 :0 ] daddr_in;  //get this signal from channel output
wire [0 :0 ] den_in;  
wire         xadc_drdy;  //assume only go high for one cycle
wire         reset;
wire         eoc_out;

assign daddr_in = {2'b00, channel_out};
assign den_in = eoc_out;
assign reset = ~rst_n;
xadc_n0_50m u_xadc (
    .di_in(16'h0000),              // input wire [15 : 0] di_in
    .daddr_in(daddr_in),        // input wire [6 : 0] daddr_in
    .den_in(den_in),            // input wire den_in
    .dwe_in(1'b1),            // input wire dwe_in
    .drdy_out(xadc_drdy),        // output wire drdy_out
    .do_out(do_out),            // output wire [15 : 0] do_out
    .dclk_in(hclk),          // input wire dclk_in
    .reset_in(reset),        // input wire reset_in
    .convst_in(convst),      // input wire convst_in
    .vp_in(1'b0),              // input wire vp_in
    .vn_in(1'b0),              // input wire vn_in
    .vauxp0(vp),            // input wire vauxp0
    .vauxn0(vn),            // input wire vauxn0
    .channel_out(channel_out),  // output wire [4 : 0] channel_out
    .eoc_out(eoc_out),          // output wire eoc_out
    .alarm_out(),      // output wire alarm_out
    .eos_out(),          // output wire eos_out
    .busy_out()        // output wire busy_out
);

//data buffer and simple fsm
//when double is 0, data store in data[11:0]
//when double is 1, two conversion result store in data[](second, first).
reg             status;  // 0 stand for first covnersion, 1 stand for second conversion
reg [23:0]      data;
wire            status_next;
wire [23:0]     data_next;

always @(posedge hclk or negedge rst_n) begin
    if (~rst_n | exit_clean) begin
        status <= 0;
        data   <= 24'b0;
    end else if (enable) begin
        status <= status_next;
        data   <= data_next;
    end
end

assign status_next = xadc_drdy? ~status: status;
assign data_next   = xadc_drdy? 
                     double? 
                     status? 
                     {do_out[15:4], data[11:0]}:
                     {12'b0, do_out[15:4]}:
                     {12'b0, do_out[15:4]}:  
                     data;

//generate drdy logic
reg xadc_drdy_delay;
always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        xadc_drdy_delay <= 1'b0;
    end else begin
        xadc_drdy_delay <= xadc_drdy;
    end
end
assign drdy = double? xadc_drdy_delay & ~status: xadc_drdy_delay;
               
//assign data to dout

assign dout = data;
endmodule