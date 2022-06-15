`timescale 1ns/100ps

module cm3_mac_tb;

parameter HCLK_PERIOD = 20;



reg hclk;
reg rst_n;
reg hready_i;
reg hwrite;
reg hsel;
reg [1:0] htrans;
reg [31:0] haddr;
reg [31:0] hwdata;
wire [31:0] hrdata;
reg [31:0] dout;
wire hready_o;
wire hresp;

`include "ahb_task.v"


cm3_mac u_cm3_mac(
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
    .hrdata   (hrdata   )
);

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
    dout     =  0;
    repeat(2) @(posedge hclk);
    rst_n =  1;
end




//one frame test

integer i = 0;




initial begin
    wait(rst_n);
    // first test  9
    @(posedge hclk);
    for (i = 0; i < 10; i = i+1) begin
        write_reg(32'h0, 32'b00111111000000000000000000000000); //0.5
        write_reg(32'h4, 32'b00111111000000000000000000000000); //0.5
    end

    @(posedge hclk);
        htrans <=    NONSEQ;
        haddr  <=    32'h0000_0008;
    @(posedge hclk);
        htrans <=    IDLE;
        haddr  <=    32'b0;
    @(posedge hclk);
        $display("======================================\n");
        $display("======================================\n");
        $display("======================================\n");
        $display("hrdata=%f\n", hrdata);
        $display("======================================\n");
        $display("======================================\n");
        $display("======================================\n");


  // second test 9
    for (i = 0; i < 10; i=i+1) begin
        write_reg(32'h0, 32'b00111111000000000000000000000000); //0.5
        write_reg(32'h4, 32'b00111111000000000000000000000000); //0.5
    end

    @(posedge hclk);
        htrans <=    NONSEQ;
        haddr  <=     32'h0000_0008;
    @(posedge hclk);
        htrans <=    IDLE;
        haddr  <=    32'b0;
    @(posedge hclk);
        $display("======================================\n");
        $display("======================================\n");
        $display("======================================\n");
        $display("hrdata=%f\n", hrdata);
        $display("======================================\n");
        $display("======================================\n");
        $display("======================================\n");



    $finish;
end



initial begin
    wait(error);
    $display("======================================\n");
    $display("======================================\n");
    $display("======================================\n");
    $display("!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!\n ");
    $display("======================================\n");
    $display("======================================\n");
    $display("======================================\n");
    $finish;
end



endmodule