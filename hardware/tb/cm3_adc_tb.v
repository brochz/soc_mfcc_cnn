`timescale 1ns/100ps

module cm3_adc_tb;

localparam HCLK_PERIOD = 20;

reg hclk;
reg rst_n;
reg hready_i;
reg hwrite;
reg hsel;
reg [1:0] htrans;
reg [31:0] haddr;
reg [31:0] hwdata;



wire [31:0] hrdata;


wire hready_o;
wire hresp;
wire int;

`include "ahb_task.v"


always #(HCLK_PERIOD/2) hclk   = ~hclk;


initial begin

    hclk     =  0;
    rst_n    =  0;
    hready_i =  1;
    hwrite   =  0;
    haddr    =  0;
    hwdata   =  0;
    htrans   =  0;
    hsel     =  1;
    #(HCLK_PERIOD*3) rst_n =  1;
end


cm3_adc dut(
    .hclk     (hclk     ),
    .rst_n    (rst_n    ),
    .hready_i (hready_i ),
    .hsel     (hsel     ),
    .hwrite   (hwrite   ),
    .htrans   (htrans   ),
    .haddr    (haddr    ),
    .hwdata   (hwdata   ),
    .hresp    (hresp    ),
    .hready_o (hready_o ),
    .hrdata   (hrdata   ),
    .vp       (1'b0     ),
    .vn       (1'b0     ),
    .int      (int      )
);

initial begin
    wait(rst_n);
    //start sampling£¬ with double mode
    write_reg(32'h0000_0000, 32'h0000_0007);  
    write_reg(32'h0000_0004, 32'h0000_0c34);
   

    #1000;
end

always @(posedge int) begin
    read_reg(32'h0000_0008);
end

endmodule
