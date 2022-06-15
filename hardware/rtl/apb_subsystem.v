// ----------------------------------------------
// Example code for
//
// System-on-Chip Design with Arm(R) Cortex(R)-M 
// Processors
//
// Reference Book
//          by Joseph Yiu, 2019 (first edition)
// 
// ISBN: 978-1-911531-19-7
// Arm Education Media
// https://www.armedumedia.com
//
// Disclaimer
// This example design is created for educational
// purpose only and are not validated to the same 
// quality level as Arm IP products. 
// Arm Education Media and author do not make any 
// warranties of these designs.
// ----------------------------------------------
// Purpose: APB subsystem for simple Cortex-M3 design
// ----------------------------------------------
// 
//

module apb_subsystem (
  input  wire         HCLK,    // Clock
  input  wire         HRESETn, // Reset

  input  wire         HSEL,    // Device select
  input  wire  [14:0] HADDR,   // Address
  input  wire  [1:0]  HTRANS,  // Transfer control
  input  wire  [2:0]  HSIZE,   // Transfer size
  input  wire         HWRITE,  // Write control
  input  wire         HNONSEC, // Security attribute (TrustZone)
  input  wire  [6:0]  HPROT,   // Protection information
  input  wire         HREADY,  // Transfer phase done
  input  wire  [31:0] HWDATA,  // Write data

  output wire         HREADYOUT, // Device ready
  output wire  [31:0] HRDATA,    // Read data output
  output wire         HRESP,     // Device response

  input  wire   [7:0] PORT0_IN,
  output wire   [7:0] PORT0_OUT,
  output wire   [7:0] PORT0_EN,

  input  wire   [7:0] PORT1_IN,
  output wire   [7:0] PORT1_OUT,
  output wire   [7:0] PORT1_EN,
  
  input  wire         TIMER0_IN,
  input  wire         TIMER1_IN,
  
  input  wire         UART0_RXD,
  output wire         UART0_TXD,
  output wire         UART0_TXEN,
  output wire         UART0_BAUDTICK,
  
  output wire         Gpio0_IRQ,
  output wire         Gpio1_IRQ,
  output wire         Timer0_IRQ,
  output wire         Timer1_IRQ,  
  output wire         Uart0_TxIRQ,
  output wire         Uart0_RxIRQ,

`ifdef FPGA_CONFIG
  // Arty S7 FPGA I/O
  input  wire   [3:0] sw,          // Switches
  output wire         led0_r,      // RGB LED 0 - R
  output wire         led0_g,      // RGB LED 0 - G
  output wire         led0_b,      // RGB LED 0 - B
  output wire         led1_r,      // RGB LED 1 - R
  output wire         led1_g,      // RGB LED 1 - G
  output wire         led1_b,      // RGB LED 1 - B
  output wire   [3:0] led,         // LEDs
  input  wire   [3:0] btn,         // Button
`endif  
  // Control signal to select if system should 
  // be reset automatically when processor entered
  // LOCKUP state
  output wire         LOCKUP_RESET_EN  
  );

  wire         PCLK;
  wire         PRESETn;
  wire  [11:0] PADDR;	  // APB Address
  wire         PENABLE;   // APB Enable
  wire         PWRITE;    // APB Write
  wire  [2:0]  PPROT;	  // APB protection information
  wire  [3:0]  PSTRB;	  // APB byte strobe
  wire  [31:0] PWDATA;    // APB write data
  wire         PSEL0;	  // APB Select (8 slaves)
  wire         PSEL1;
  wire         PSEL2;
  wire         PSEL3;
  wire         PSEL4;
  wire         PSEL5;
  wire         PSEL6;
  wire         PSEL7;
        		   // APB Inputs
  wire  [31:0] PRDATA0;    // Read data for each APB slave
  wire  [31:0] PRDATA1;
  wire  [31:0] PRDATA2;
  wire  [31:0] PRDATA3;
  wire  [31:0] PRDATA4;
  wire  [31:0] PRDATA5;
  wire  [31:0] PRDATA6;
  wire  [31:0] PRDATA7;
  wire         PREADY0;    // Ready for each APB slave
  wire         PREADY1;
  wire         PREADY2;
  wire         PREADY3;
  wire         PREADY4;
  wire         PREADY5;
  wire         PREADY6;
  wire         PREADY7;
  wire         PSLVERR0;   // Error state for each APB slave
  wire         PSLVERR1;
  wire         PSLVERR2;
  wire         PSLVERR3;
  wire         PSLVERR4;
  wire         PSLVERR5;
  wire         PSLVERR6;
  wire         PSLVERR7;

  assign PCLK    = HCLK;
  assign PRESETn = HRESETn;
  
  // ---------------------------------
  // AHB to APB bridge
  ahb_to_apb u_ahb_to_apb (
  .HCLK            (HCLK),    // Clock
  .HRESETn         (HRESETn), // Reset
  .HSEL            (HSEL),
  .HADDR           (HADDR[14:0]),
  .HTRANS          (HTRANS[1:0]),
  .HSIZE           (HSIZE[2:0]),
  .HWRITE          (HWRITE),
  .HNONSEC         (HNONSEC),
  .HPROT           (HPROT[6:0]),
  .HREADY          (HREADY),
  .HWDATA          (HWDATA[31:0]),
  .HREADYOUT       (HREADYOUT),
  .HRDATA          (HRDATA[31:0]),
  .HRESP           (HRESP),

  .PADDR           (PADDR[11:0]),   
  .PENABLE         (PENABLE), 
  .PWRITE          (PWRITE),  
  .PPROT           (PPROT),   
  .PSTRB           (PSTRB),   
  .PWDATA          (PWDATA),  
  .PSEL0           (PSEL0),   
  .PSEL1           (PSEL1),
  .PSEL2           (PSEL2),
  .PSEL3           (PSEL3),
  .PSEL4           (PSEL4),
  .PSEL5           (PSEL5),
  .PSEL6           (PSEL6),
  .PSEL7           (PSEL7),
  	   
  .PRDATA0         (PRDATA0), 
  .PRDATA1         (PRDATA1),
  .PRDATA2         (PRDATA2),
  .PRDATA3         (PRDATA3),
  .PRDATA4         (PRDATA4),
  .PRDATA5         (PRDATA5),
  .PRDATA6         (PRDATA6),
  .PRDATA7         (PRDATA7),
  .PREADY0         (PREADY0), 
  .PREADY1         (PREADY1),
  .PREADY2         (PREADY2),
  .PREADY3         (PREADY3),
  .PREADY4         (PREADY4),
  .PREADY5         (PREADY5),
  .PREADY6         (PREADY6),
  .PREADY7         (PREADY7),
  .PSLVERR0        (PSLVERR0),
  .PSLVERR1        (PSLVERR1),
  .PSLVERR2        (PSLVERR2),
  .PSLVERR3        (PSLVERR3),
  .PSLVERR4        (PSLVERR4),
  .PSLVERR5        (PSLVERR5),
  .PSLVERR6        (PSLVERR6),
  .PSLVERR7        (PSLVERR7)
  );

  // ---------------------------------
  apb_gpio #(
  .PortWidth (8)
  ) u_apb_gpio_0 (
  .PCLK            (PCLK),    // Clock
  .PRESETn         (PRESETn), // Reset
     // APB interface inputs
  .PSEL            (PSEL0),    // Device select
  .PADDR           (PADDR[7:2]),
  .PENABLE         (PENABLE),
  .PWRITE          (PWRITE),
  .PWDATA          (PWDATA[31:0]),
   // APB interface outputs
  .PREADY          (PREADY0),
  .PRDATA          (PRDATA0[31:0]),
  .PSLVERR         (PSLVERR0),
   
  // GPIO Interface inputs and output
  .PORTIN          (PORT0_IN[7:0]),  // GPIO input
  .PORTOUT         (PORT0_OUT[7:0]), // GPIO output
  .PORTEN          (PORT0_EN[7:0]),  // GPIO output enable
  .GPIOINT         (), // Individual interrupts not used in this example
  .COMBINT         (Gpio0_IRQ) // Combined interrupt  
  );

  // ---------------------------------
  apb_gpio #(
  .PortWidth (8)
  ) u_apb_gpio_1 (
  .PCLK            (PCLK),    // Clock
  .PRESETn         (PRESETn), // Reset
     // APB interface inputs
  .PSEL            (PSEL1),    // Device select
  .PADDR           (PADDR[7:2]),
  .PENABLE         (PENABLE),
  .PWRITE          (PWRITE),
  .PWDATA          (PWDATA[31:0]),
   // APB interface outputs
  .PREADY          (PREADY1),
  .PRDATA          (PRDATA1[31:0]),
  .PSLVERR         (PSLVERR1),
   
  // GPIO Interface inputs and output
  .PORTIN          (PORT1_IN[7:0]),  // GPIO input
  .PORTOUT         (PORT1_OUT[7:0]), // GPIO output
  .PORTEN          (PORT1_EN[7:0]),  // GPIO output enable
  .GPIOINT         (), // Individual interrupts not used in this example
  .COMBINT         (Gpio1_IRQ) // Combined interrupt  
  );

  // ---------------------------------
  apb_timer u_apb_timer_0 (
  .PCLK            (PCLK),    // Clock
  .PRESETn         (PRESETn), // Reset
     // APB interface inputs
  .PSEL            (PSEL2),    // Device select
  .PADDR           (PADDR[7:2]),
  .PENABLE         (PENABLE),
  .PWRITE          (PWRITE),
  .PWDATA          (PWDATA[31:0]),
   // APB interface outputs
  .PREADY          (PREADY2),
  .PRDATA          (PRDATA2[31:0]),
  .PSLVERR         (PSLVERR2),
   
  // GPIO Interface inputs and output
  .EXTIN           (TIMER0_IN),  // Timer external input
  .TIMERINT        (Timer0_IRQ)  // Timer interrupt
  );

  // ---------------------------------
  apb_timer u_apb_timer_1 (
  .PCLK            (PCLK),    // Clock
  .PRESETn         (PRESETn), // Reset
     // APB interface inputs
  .PSEL            (PSEL3),    // Device select
  .PADDR           (PADDR[7:2]),
  .PENABLE         (PENABLE),
  .PWRITE          (PWRITE),
  .PWDATA          (PWDATA[31:0]),
   // APB interface outputs
  .PREADY          (PREADY3),
  .PRDATA          (PRDATA3[31:0]),
  .PSLVERR         (PSLVERR3),
   
  // GPIO Interface inputs and output
  .EXTIN           (TIMER1_IN),  // Timer external input
  .TIMERINT        (Timer1_IRQ)  // Timer interrupt
  );
  // ---------------------------------
  apb_uart u_apb_uart_0 (
  .PCLK            (PCLK),    // Clock
  .PRESETn         (PRESETn), // Reset
     // APB interface inputs
  .PSEL            (PSEL4),    // Device select
  .PADDR           (PADDR[7:2]),
  .PENABLE         (PENABLE),
  .PWRITE          (PWRITE),
  .PWDATA          (PWDATA[31:0]),
   // APB interface outputs
  .PREADY          (PREADY4),
  .PRDATA          (PRDATA4[31:0]),
  .PSLVERR         (PSLVERR4),
  .RXD             (UART0_RXD),
  .TXD             (UART0_TXD),
  .TXEN            (UART0_TXEN),
  .BAUDTICK        (UART0_BAUDTICK),
  .TXINT           (Uart0_TxIRQ),
  .RXINT           (Uart0_RxIRQ)
  );
  // ---------------------------------
  // Unused address slots
  assign PRDATA5  = {32{1'b0}};
  assign PREADY5  = 1'b1;
  assign PSLVERR5 = 1'b0;

  assign PRDATA6  = {32{1'b0}};
  assign PREADY6  = 1'b1;
  assign PSLVERR6 = 1'b0;

  // ---------------------------------
  // Optional System Control register block
  
`ifdef INCLUDE_SYSCTRL_REGBLK
  apb_sys_ctrl_reg u_apb_sys_ctrl_reg_0 (
  .PCLK            (PCLK),    // Clock
  .PRESETn         (PRESETn), // Reset
     // APB interface inputs
  .PSEL            (PSEL7),    // Device select
  .PADDR           (PADDR[7:2]),
  .PENABLE         (PENABLE),
  .PWRITE          (PWRITE),
  .PWDATA          (PWDATA[31:0]),
  .PPROT           (PPROT[2:0]),
   // APB interface outputs
  .PREADY          (PREADY7),
  .PRDATA          (PRDATA7[31:0]),
  .PSLVERR         (PSLVERR7),

`ifdef FPGA_CONFIG
  .sw              (sw),
  .led0_r          (led0_r),
  .led0_g          (led0_g),
  .led0_b          (led0_b),
  .led1_r          (led1_r),
  .led1_g          (led1_g),
  .led1_b          (led1_b),
  .led             (led),
  .btn             (btn),
`endif    
  .LOCKUP_RESET_EN (LOCKUP_RESET_EN)
  );
`else
  
  assign PRDATA7  = {32{1'b0}};
  assign PREADY7  = 1'b1;
  assign PSLVERR7 = 1'b0;
  assign LOCKUP_RESET_EN = 1'b0;
`endif
endmodule
