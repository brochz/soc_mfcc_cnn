`timescale 1 ns / 1ns


module top_tb  ;

reg clk, rstn;
wire [7:0] led_pin;
wire [7:0] io;
wire SWDIO = 0;
fpga_top u_fpga_top(
    .sys_clk_in (clk),
    .sys_rst_n  (rstn  ),
    .led_pin    (led_pin),
    .io(io),
    .SWCLK(1'b0),
    .SWDIO(SWDIO),
    .VP(1'b0),
    .VN(1'b1),
    .Uart_rxd(1'b1)
);


always #(10) clk = ~clk;
initial begin
    rstn = 0;
    clk = 0;

    repeat(10) @(posedge clk);
    rstn = 1;

end




endmodule