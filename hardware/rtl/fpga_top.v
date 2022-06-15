module fpga_top (
    input sys_clk_in,
    input sys_rst_n,
//FPGA led_pin and gpio
    inout [7:0] led_pin,
    inout [7:0] io,
//debug
    input SWCLK,
    inout SWDIO,
//ADC  VAUXx[0] only
    input VP,
    input VN,
//UART
    input  Uart_rxd, //
    output Uart_txd //
);
//!!!!!hclk = 46MHZ
wire hclk;
mmcm_100_50 u_mmcm
(
// Clock out ports
.clk_out(hclk),     // output clk_out
// Clock in ports
.clk_in(sys_clk_in));      // input clk_in

cm3_mcu u_cm3_mcu(
    .RSTn      (sys_rst_n      ),
    .CLK       (hclk           ),

    .PORT0     (led_pin        ),
    .PORT1     (io             ),
    .SWCLKTCK  (SWCLK          ),
    .SWDTMS    (SWDIO          ),
    .UART0_RXD (Uart_rxd       ),
    .UART0_TXD (Uart_txd       ),
    .VP        (VP             ),
    .VN        (VN             ),
    .TIMER0_IN (1'b0           ),
    .TIMER1_IN (1'b0           )
);  

endmodule