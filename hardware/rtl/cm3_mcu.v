module cm3_mcu (
    input RSTn,
    input CLK,

//debug 
    input       SWCLKTCK,
    inout       SWDTMS,

//gpio
    inout [7:0] PORT0,
    inout [7:0] PORT1,
//timer
    input       TIMER0_IN,
    input       TIMER1_IN,
//ADC
    input       VP,
    input       VN,
//UART
    input       UART0_RXD,
    output      UART0_TXD
);


wire  [7:0] PORT0_IN;
wire  [7:0] PORT0_OUT;
wire  [7:0] PORT0_EN;
wire  [7:0] PORT0_ENn;

wire  [7:0] PORT1_IN;
wire  [7:0] PORT1_OUT;
wire  [7:0] PORT1_EN;
wire  [7:0] PORT1_ENn;

wire SWDOENn;
assign PORT0_ENn = ~PORT0_EN;
assign PORT1_ENn = ~PORT1_EN;
assign SWDOENn   = ~SWDOEN;


cm3_system_top u_cm3_system_top(
    .FCLK           (FCLK           ), //ok
    .HCLK           (HCLK           ), //ok
    .HRESETn        (HRESETn        ), //ok
    .PORESETn       (PORESETn       ), //ok
    .LOCKUPRESET    (LOCKUPRESET    ), //ok

    .SYSRESETREQ    (SYSRESETREQ    ), //ok

    .SWDITMS        (SWDITMS        ),
    .SWCLKTCK       (SWCLKTCK       ), //OK
    .SWDOEN         (SWDOEN         ),
    .SWDO           (SWDO           ), 

    .PORT0_IN       (PORT0_IN       ), //ok
    .PORT0_OUT      (PORT0_OUT      ), //ok
    .PORT0_EN       (PORT0_EN       ), //ok

    .PORT1_IN       (PORT1_IN       ), //ok
    .PORT1_OUT      (PORT1_OUT      ), //ok
    .PORT1_EN       (PORT1_EN       ), //ok

    .TIMER0_IN      (TIMER0_IN      ), //OK
    .TIMER1_IN      (TIMER1_IN      ), //OK

    //ADC
    .VP             (VP             ),
    .VN             (VN             ),

    .UART0_RXD      (UART0_RXD      ), //OK
    .UART0_TXD      (UART0_TXD      ), //OK
    .UART0_TXEN     (),
    .UART0_BAUDTICK ()
);


clk_reset_ctrl u_clk_reset_ctrl(
    .CLKIN       (CLK         ),
    .nSRSTIN     (RSTn        ),
    .SYSRESETREQ (SYSRESETREQ ),
    .LOCKUPRESET (LOCKUPRESET ),
    .GATEHCLK    (1'b0        ),  //no gate clock
    .TRCENA      (1'b0        ),  //no trace

    .FCLK        (FCLK        ),
    .HCLK        (HCLK        ),
    .TRACECLKIN  (            ), //no trace
    .PORESETn    (PORESETn    ),
    .HRESETn     (HRESETn     )
);

//xilix IOBUF is low active output
IOBUF  IOBUF_00 (
    .O(PORT0_IN[0]),     // Buffer output
    .IO(PORT0[0]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT0_OUT[0]),     // Buffer input
    .T(PORT0_ENn[0])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_01 (
    .O(PORT0_IN[1]),     // Buffer output
    .IO(PORT0[1]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT0_OUT[1]),     // Buffer input
    .T(PORT0_ENn[1])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_02 (
    .O(PORT0_IN[2]),     // Buffer output
    .IO(PORT0[2]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT0_OUT[2]),     // Buffer input
    .T(PORT0_ENn[2])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_03 (
    .O(PORT0_IN[3]),     // Buffer output
    .IO(PORT0[3]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT0_OUT[3]),     // Buffer input
    .T(PORT0_ENn[3])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_04 (
    .O(PORT0_IN[4]),     // Buffer output
    .IO(PORT0[4]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT0_OUT[4]),     // Buffer input
    .T(PORT0_ENn[4])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_05 (
    .O(PORT0_IN[5]),     // Buffer output
    .IO(PORT0[5]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT0_OUT[5]),     // Buffer input
    .T(PORT0_ENn[5])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_06 (
    .O(PORT0_IN[6]),     // Buffer output
    .IO(PORT0[6]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT0_OUT[6]),     // Buffer input
    .T(PORT0_ENn[6])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_07 (
    .O(PORT0_IN[7]),     // Buffer output
    .IO(PORT0[7]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT0_OUT[7]),     // Buffer input
    .T(PORT0_ENn[7])      // 3-state enable input, high=input, low=output
);


IOBUF  IOBUF_10 (
    .O(PORT1_IN[0]),     // Buffer output
    .IO(PORT1[0]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT1_OUT[0]),     // Buffer input
    .T(PORT1_ENn[0])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_11 (
    .O(PORT1_IN[1]),     // Buffer output
    .IO(PORT1[1]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT1_OUT[1]),     // Buffer input
    .T(PORT1_ENn[1])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_12 (
    .O(PORT1_IN[2]),     // Buffer output
    .IO(PORT1[2]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT1_OUT[2]),     // Buffer input
    .T(PORT1_ENn[2])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_13 (
    .O(PORT1_IN[3]),     // Buffer output
    .IO(PORT1[3]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT1_OUT[3]),     // Buffer input
    .T(PORT1_ENn[3])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_14 (
    .O(PORT1_IN[4]),     // Buffer output
    .IO(PORT1[4]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT1_OUT[4]),     // Buffer input
    .T(PORT1_ENn[4])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_15 (
    .O(PORT1_IN[5]),     // Buffer output
    .IO(PORT1[5]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT1_OUT[5]),     // Buffer input
    .T(PORT1_ENn[5])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_16 (
    .O(PORT1_IN[6]),     // Buffer output
    .IO(PORT1[6]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT1_OUT[6]),     // Buffer input
    .T(PORT1_ENn[6])      // 3-state enable input, high=input, low=output
);

IOBUF  IOBUF_17 (
    .O(PORT1_IN[7]),     // Buffer output
    .IO(PORT1[7]),   // Buffer inout port (connect directly to top-level port)
    .I(PORT1_OUT[7]),     // Buffer input
    .T(PORT1_ENn[7])      // 3-state enable input, high=input, low=output
);


IOBUF  IOBUF_SWD (
    .O(SWDITMS),     // Buffer output
    .IO(SWDTMS),   // Buffer inout port (connect directly to top-level port)
    .I(SWDO),     // Buffer input
    .T(SWDOENn)      // 3-state enable input, high=input, low=output
);




    
endmodule