`timescale 1 ns / 100 ps
module xadc_wrapper_tb;
parameter PERIOD = 20;   //50Mhz

reg       hclk;
reg       rst_n;
reg       enable;
reg       double;
reg[15:0] div;
wire[23:0]dout;
//clock 
initial hclk = 0;
always #(PERIOD/2) hclk = ~hclk;


xadc_wrapper u_xadc_wrapper(
    .hclk   (hclk   ),
    .rst_n  (rst_n  ),
    .enable (enable ),
    .double (double ),
    .div    (div    ),
    .vp     (1'b0   ),
    .vn     (1'b0   ),
    .dout   (dout   ),
    .drdy   (drdy   )
);

//initial the device 
initial begin
    rst_n = 0;
    #100;
    @(posedge hclk) begin
    rst_n = 01'b1;
    end 
end

// //PAT1: normal test, div=0xff, double=0
// initial begin
//     div = 12'd3125;  //div must great than some value
//     double = 0;
//     wait(rst_n);
//     #(PERIOD*50);
//     enable = 1;
//     #100000;
// end


//PAT2: double sample test, div=0xff, double=1
initial begin
    div = 16'hffff;  //div must great than some value
    double = 1;
    enable = 1;
    wait(rst_n);
    #(PERIOD*50);
    wait(drdy);
    #100000;

end

















endmodule