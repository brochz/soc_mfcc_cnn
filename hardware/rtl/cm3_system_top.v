module cm3_system_top (
   //clock and reset
   input  wire        FCLK,
   input  wire        HCLK,
   input  wire        HRESETn,
   input  wire        PORESETn,

   output wire        LOCKUPRESET,     //lockup reset ???
   output wire        SYSRESETREQ,


   // Debug  pins
   input  wire        SWDITMS,            // Test Mode Select/SWDIN
   input  wire        SWCLKTCK,           // Test clock / SWCLK
   output wire        SWDOEN,             // SingleWire output enable
   output wire        SWDO,               // SingleWire data out

   // Peripherals
   input  wire  [7:0] PORT0_IN,
   output wire  [7:0] PORT0_OUT,
   output wire  [7:0] PORT0_EN,

   input  wire  [7:0] PORT1_IN,
   output wire  [7:0] PORT1_OUT,
   output wire  [7:0] PORT1_EN,

   input  wire        TIMER0_IN,
   input  wire        TIMER1_IN,

   input  wire        UART0_RXD,
   output wire        UART0_TXD,
   output wire        UART0_TXEN,
   output wire        UART0_BAUDTICK,

   //ADC
   input  wire        VP, 
   input  wire        VN 

);

//===============================================================================//
// Bus wire Declaration                                                              //
//===============================================================================//
// ICode
wire     [1:0] HTRANSI;    // ICode-bus transfer type
wire     [2:0] HSIZEI;     // ICode-bus transfer size
wire    [31:0] HADDRI;     // ICode-bus address
wire     [2:0] HBURSTI;    // ICode-bus burst length
wire     [3:0] HPROTI;     // ICode-bus protection
wire     [1:0] MEMATTRI;   // ICode-bus memory attributes
wire           HREADYI;    // ICode-bus ready
wire    [31:0] HRDATAI;    // ICode-bus read data
wire     [1:0] HRESPI;     // ICode-bus transfer response

// DCode
wire     [1:0] HMASTERD;   // DCode-bus master
wire     [1:0] HTRANSD;    // DCode-bus transfer type
wire     [2:0] HSIZED;     // DCode-bus transfer size
wire    [31:0] HADDRD;     // DCode-bus address
wire     [2:0] HBURSTD;    // DCode-bus burst length
wire     [3:0] HPROTD;     // DCode-bus protection
wire     [1:0] MEMATTRD;   // DCode-bus memory attributes
wire           EXREQD;     // DCode-bus exclusive request
wire           HWRITED;    // DCode-bus write not read
wire    [31:0] HWDATAD;    // DCode-bus write data
wire           HREADYD;    // DCode-bus ready
wire    [31:0] HRDATAD;    // DCode-bus read data
wire     [1:0] HRESPD;     // DCode-bus transfer response
wire           EXRESPD;    // DCode-bus exclusive response


//System bus 
wire     [1:0] HMASTERS;   // System-bus master
wire     [1:0] HTRANSS;    // System-bus transfer type
wire     [2:0] HSIZES;     // System-bus transfer size
wire    [31:0] HADDRS;     // System-bus address
wire     [2:0] HBURSTS;    // System-bus burst length
wire     [3:0] HPROTS;     // System-bus protection
wire           HWRITES;    // System-bus write not read
wire    [31:0] HWDATAS;    // System-bus write data
wire           HREADYS;    // System-bus ready
wire    [31:0] HRDATAS;    // System-bus read data
wire           HRESPS;     // System-bus transfer response

//merged code bus
wire  [1:0] CODE_HMASTER;   // Code-bus master
wire  [1:0] CODE_HTRANS;    // Code-bus transfer type
wire        CODE_HWRITE;    // Code-bus write not read
wire  [2:0] CODE_HSIZE;     // Code-bus transfer size
wire [31:0] CODE_HADDR;     // Code-bus address
wire [31:0] CODE_HWDATA;    // Code-bus write data
wire  [2:0] CODE_HBURST;    // Code-bus burst length
wire  [3:0] CODE_HPROT;     // Code-bus protection
wire        CODE_HREADY;    // Code-bus ready
wire [31:0] CODE_HRDATA;    // Code-bus read data
wire        CODE_HRESPEC;

//240 interrupts 
wire [239:0] CM3_INTERRUPTS;

//===============================================================================//
// Cortex m3 Instant                                                            //
//===============================================================================//
CORTEXM3INTEGRATIONDS u_CORTEXM3INTEGRATIONDS(
    
   .FCLK           (FCLK),
   .HCLK           (HCLK),
   .TRACECLKIN     (1'b0),  //no trace
   .PORESETn       (PORESETn),
   .SYSRESETn      (HRESETn),
   

   // I-CODE bus
   .HTRANSI        (HTRANSI), 
   .HSIZEI         (HSIZEI),  
   .HADDRI         (HADDRI),  
   .HBURSTI        (HBURSTI), 
   .HPROTI         (HPROTI),  
   .MEMATTRI       (MEMATTRI), // not use 
   .HREADYI        (HREADYI), 
   .HRDATAI        (HRDATAI), 
   .HRESPI         (HRESPI), 
   .IFLUSH         (1'b0),
   
   // D-CODE bus
   .HMASTERD       (HMASTERD), 
   .HTRANSD        (HTRANSD), 
   .HSIZED         (HSIZED), 
   .HADDRD         (HADDRD), 
   .HBURSTD        (HBURSTD), 
   .HPROTD         (HPROTD), 
   .MEMATTRD       (MEMATTRD),  // not use 
   .EXREQD         (EXREQD), 
   .HWRITED        (HWRITED), 
   .HWDATAD        (HWDATAD), 
   .HREADYD        (HREADYD), 
   .HRDATAD        (HRDATAD), 
   .HRESPD         (HRESPD), 
   .EXRESPD        (EXRESPD),  

   // System bus
   .HMASTERS       (HMASTERS), 
   .HTRANSS        (HTRANSS), 
   .HSIZES         (HSIZES), 
   .HADDRS         (HADDRS), 
   .HBURSTS        (HBURSTS), 
   .HPROTS         (HPROTS), // not use 
   .HMASTLOCKS     (), // not use
   .MEMATTRS       (), // not use 
   .EXREQS         (), // not use
   .HWRITES        (HWRITES), 
   .HWDATAS        (HWDATAS), 
   .HREADYS        (HREADYS), 
   .HRDATAS        (HRDATAS), 
   .HRESPS         ({1'b0, HRESPS}),  //!
   .EXRESPS        (1'b0),  // always success
    
   .WICENREQ       (1'b1),  //not use //!!! 
   .WICENACK       (),      //not use
   .MPUDISABLE     (1'b0), // MPU available to use
   .DBGEN          (1'b1), // enable debug
   .NIDEN          (1'b0), // disable trace
   .DNOTITRANS     (1'b1), // simple code mux is used
   .BIGEND         (1'b0),
   
   .EDBGRQ         (1'b0),  // Debug Request
   .DBGRESTART     (1'b0),  // External Debug Restart request
   .DBGRESTARTED   (),
   .FIXMASTERTYPE  (1'b1),
   .AUXFAULT       ({32{1'b0}}),
   
   .STCLK          (1'b0), // No reference clock
   .STCALIB        ({2'b11,{24{1'b0}}}), // No ref
   .INTISR         (CM3_INTERRUPTS),    //ok
   .INTNMI         (1'b0),             //not use
   
   .SLEEPING       (),  //no low power
   .SLEEPDEEP      (), //no low power
   .GATEHCLK       (),  // when high, HCLK can be turned off, no low power
   .SLEEPHOLDREQn  (1'b1),
   .SLEEPHOLDACKn  (),
   
   .RXEV           (1'b0),   
   .TXEV           (),
   .WAKEUP         (),      //no low power
   
//SWD 
   .SWDITMS        (SWDITMS), //SW DIN
   .SWCLKTCK       (SWCLKTCK), //SW CLK
   .SWDO           (SWDO),  // SingleWire data out
   .SWDOEN         (SWDOEN), // SingleWire output enable

   .TDI            (1'b0), //no jtag
   .TDO            (),     //no jtag
   .nTDOEN         (),
   .JTAGNSW        (),
   .SWV            (),
   .TRACECLK       (),
   .TRACEDATA      (),
   .TRCENA         (),      //no truce
   .nTRST          (1'b1),  //no jtag

   .TSVALUEB       (48'b0),  //no timestamp 
   .SYSRESETREQ    (SYSRESETREQ),
   
   .CDBGPWRUPREQ   (CDBGPWRUPREQ),
   .CDBGPWRUPACK   (CDBGPWRUPACK),
   
   .ETMINTNUM      (),
   .ETMINTSTAT     (),
   .CURRPRI        (),
   .LOCKUP         (LOCKUP),
   .HALTED         (),
   .BRCHSTAT       (),
   .HTMDHADDR      (),  // HTM data HADDR
   .HTMDHTRANS     (),  // HTM data HTRANS
   .HTMDHSIZE      (),  // HTM data HSIZE
   .HTMDHBURST     (),  // HTM data HBURST
   .HTMDHPROT      (),  // HTM data HPROT
   .HTMDHWDATA     (),  // HTM data HWDATA
   .HTMDHWRITE     (),  // HTM data HWRITE
   .HTMDHRDATA     (),  // HTM data HRDATA
   .HTMDHREADY     (),  // HTM data HREADY
   .HTMDHRESP      (),  // HTM data HRESP

   
   .ISOLATEn       (1'b1),   
   .RETAINn        (1'b1),   
   .SE             (1'b0),
   .RSTBYPASS      (1'b0),
   .CGBYPASS       (1'b0)
);




//===============================================================================//
// I-BUS AND D-BUS Connection                                                    //
//===============================================================================//
//assign I bus and D bus with code memory
//#1.first mux the I and D AHB bus
// Merging of I-CODE and D-CODE bus
//dont care abour PROT signal and MEMATTR
cm3_code_mux u_cm3_code_mux (
  .HCLK            (HCLK),    // Clock
  .HRESETn         (HRESETn), // Reset

  //----- I-CODE -----------
  .HADDRI          (HADDRI),
  .HTRANSI         (HTRANSI[1:0]),
  .HSIZEI          (HSIZEI[2:0]),
  .HBURSTI         (HBURSTI[2:0]),
  .HPROTI          (HPROTI[3:0]),
  
  .HRDATAI         (HRDATAI[31:0]),
  .HREADYI         (HREADYI),
  .HRESPI          (HRESPI[1:0]),

  //----- D-CODE -----------
  .HADDRD          (HADDRD),
  .HTRANSD         (HTRANSD[1:0]),
  .HSIZED          (HSIZED[2:0]),
  .HBURSTD         (HBURSTD[2:0]),
  .HPROTD          (HPROTD[3:0]),
  .HWDATAD         (HWDATAD[31:0]),
  .HWRITED         (HWRITED),
  .EXREQD          (EXREQD),

  .HRDATAD         (HRDATAD[31:0]),
  .HREADYD         (HREADYD),
  .HRESPD          (HRESPD[1:0]),
  .EXRESPD         (EXRESPD),

  //----- CODE -----------
  .HADDRC          (CODE_HADDR),
  .HTRANSC         (CODE_HTRANS),
  .HSIZEC          (CODE_HSIZE),
  .HBURSTC         (CODE_HBURST),
  .HPROTC          (CODE_HPROT),
  .HWDATAC         (CODE_HWDATA),
  .HWRITEC         (CODE_HWRITE),
  .EXREQC          (),           //not use EXREQC

  .HRDATAC         (CODE_HRDATA),
  .HREADYC         (CODE_HREADY),       
  .HRESPC          ({1'b0, CODE_HRESPEC}), //one bit response to two bit
  .EXRESPC         (1'b0)   // always success
);

//#2. SLAVE MUX
// Code bus AHB decoder 
//256k rom 18 bit width rom 
wire [31:0] HRDATA_RAM_C;
ahb_decoder_code u_ahb_decoder_code (
  .HADDR           (CODE_HADDR),
  .HSEL_ROM        (HSEL_ROM),
  .HSEL_DefSlave   (HSEL_DefSlave_C)
  );

//ahb slave mux
cmsdk_ahb_slave_mux 
#(
   .PORT0_ENABLE (1),
   .PORT1_ENABLE (1),
   .PORT2_ENABLE (0),
   .PORT3_ENABLE (0),
   .PORT4_ENABLE (0),
   .PORT5_ENABLE (0),
   .PORT6_ENABLE (0),
   .PORT7_ENABLE (0),
   .PORT8_ENABLE (0),
   .PORT9_ENABLE (0),
   .DW           (32)
)
u_cmsdk_ahb_slave_mux_code(
   .HCLK       (HCLK       ), //ok
   .HRESETn    (HRESETn    ), //ok

   .HREADY     (CODE_HREADY), //ok

   .HSEL0      (HSEL_ROM        ), //ok
   .HREADYOUT0 (HREADYOUT_RAM_C ), //ok
   .HRESP0     (HRESP_RAM_C     ), //ok
   .HRDATA0    (HRDATA_RAM_C    ), //ok

   //default slave
   .HSEL1      (HSEL_DefSlave_C), //ok
   .HREADYOUT1 (HREADYOUT_DefSlave_C),//ok
   .HRESP1     (HRESP1_DefSlave_C), //ok
   .HRDATA1    (32'b0), //ok

   .HREADYOUT  (CODE_HREADY), //to CODE, system level hready to all slaves
   .HRESP      (CODE_HRESPEC), //to CODE 
   .HRDATA     (CODE_HRDATA )  //to CODE 
);
//code default slave 
cmsdk_ahb_default_slave u_cmsdk_ahb_default_slave_c(
   .HCLK      (HCLK                 ),
   .HRESETn   (HRESETn              ),

   .HSEL      (HSEL_DefSlave_C),
   .HTRANS    (CODE_HTRANS          ),
   .HREADY    (CODE_HREADY          ),
   .HREADYOUT (HREADYOUT_DefSlave_C ),
   .HRESP     (HRESP1_DefSlave_C    )    //one bit
);

//#3.fpga ahb->sram
wire [31:0] SRAMRDATA_C, SRAMWDATA_C;
wire [3:0]  SRAMWEN_C;
wire [13:0] SRAMADDR_C;    //64kb
cmsdk_ahb_to_sram 
#(
   .AW (16)
)
u_cmsdk_ahb_to_sram_c(
   .HCLK      (HCLK               ),
   .HRESETn   (HRESETn            ),

   .HSEL      (HSEL_ROM           ),
   .HREADY    (CODE_HREADY        ),
   .HTRANS    (CODE_HTRANS        ),
   .HSIZE     (CODE_HSIZE         ),
   .HWRITE    (CODE_HWRITE        ),
   .HADDR     (CODE_HADDR[15:0]   ),    //64kb
   .HWDATA    (CODE_HWDATA        ),      
   .HREADYOUT (HREADYOUT_RAM_C    ),
   .HRESP     (HRESP_RAM_C        ),
   .HRDATA    (HRDATA_RAM_C       ),

   .SRAMRDATA (SRAMRDATA_C        ), //32bit
   .SRAMADDR  (SRAMADDR_C         ), //ADW = 16
   .SRAMWEN   (SRAMWEN_C          ), //4bit
   .SRAMWDATA (SRAMWDATA_C        ), //32bit 
   .SRAMCS    (SRAMCS_C           )  //cs
);


cmsdk_fpga_sram 
#(
   .AW       (14       ),  //64kb
   .MEMFILE  ("image.mem")
)
u_cmsdk_fpga_sram_c(
   .CLK   (HCLK        ),
   .ADDR  (SRAMADDR_C  ),
   .WDATA (SRAMWDATA_C ),
   .WREN  (SRAMWEN_C   ),
   .CS    (SRAMCS_C    ),
   .RDATA (SRAMRDATA_C )
);


//===============================================================================//
// System  Bus connection                                                        //
//===============================================================================//

//wire decleration
wire [31:0] HRDATA_APB;
wire [31:0] HRDATA_CM3_ADC;
wire [31:0] HRDATA_CM3_FFT;
wire [31:0] HRDATA_CM3_MAC;
wire [31:0] HRDATA_CM3_MAC_1;
wire [31:0] HRDATA_CM3_LOG;
wire [31:0] HRDATA_RAM_S;
//ahb addr decoder 
ahb_decoder_system u_ahb_decoder_system (
  .HADDR           (HADDRS),
  .HSEL_RAM        (HSEL_RAM),
  .HSEL_APB        (HSEL_APB),
  .HSEL_CM3_ADC    (HSEL_CM3_ADC),
  .HSEL_CM3_FFT    (HSEL_CM3_FFT),
  .HSEL_CM3_MAC    (HSEL_CM3_MAC),
  .HSEL_CM3_MAC_1  (HSEL_CM3_MAC_1),
  .HSEL_CM3_LOG    (HSEL_CM3_LOG),
  .HSEL_DefSlave   (HSEL_DefSlave_S)
);

cmsdk_ahb_slave_mux 
#(
   .PORT0_ENABLE (1            ),  //to RAM
   .PORT1_ENABLE (1            ),  //to APB brige
   .PORT2_ENABLE (1            ),  //to default slave
   .PORT3_ENABLE (1            ),  //to cm3 adc
   .PORT4_ENABLE (1            ),  //to cm3 fft
   .PORT5_ENABLE (1            ),  //to cm3 mac
   .PORT6_ENABLE (1            ),  //to cm3 mac_1
   .PORT7_ENABLE (1            ),  //to cm3 log
   .PORT8_ENABLE (0            ),
   .PORT9_ENABLE (0            ),
   .DW           (32           )
)
u_cmsdk_ahb_slave_mux(
   .HCLK       (HCLK       ), //ok
   .HRESETn    (HRESETn    ), //ok
   .HREADY     (HREADYS    ), //ok

//to ram, ok
   .HSEL0      (HSEL_RAM        ), 
   .HREADYOUT0 (HREADYOUT_RAM_S ),
   .HRESP0     (HRESP_RAM_S     ),
   .HRDATA0    (HRDATA_RAM_S    ),

//to APB, ok
   .HSEL1      (HSEL_APB        ),
   .HREADYOUT1 (HREADYOUT_APB   ),
   .HRESP1     (HRESP_APB       ),
   .HRDATA1    (HRDATA_APB      ),


//to default slave, ok
   .HSEL2      (HSEL_DefSlave_S      ),
   .HREADYOUT2 (HREADYOUT_DefSlave_S ),
   .HRESP2     (HRESP_DefSlave_S     ),
   .HRDATA2    (32'b0                ),

//to cm3_adc, ok
   .HSEL3      (HSEL_CM3_ADC         ),
   .HREADYOUT3 (HREADYOUT_CM3_ADC    ),
   .HRESP3     (HRESP_CM3_ADC        ),
   .HRDATA3    (HRDATA_CM3_ADC       ),


//to cm3_fft, ok
   .HSEL4      (HSEL_CM3_FFT         ),
   .HREADYOUT4 (HREADYOUT_CM3_FFT    ),
   .HRESP4     (HRESP_CM3_FFT        ),
   .HRDATA4    (HRDATA_CM3_FFT       ),

//to cm3_mac, ok
   .HSEL5      (HSEL_CM3_MAC         ),
   .HREADYOUT5 (HREADYOUT_CM3_MAC    ),
   .HRESP5     (HRESP_CM3_MAC        ),
   .HRDATA5    (HRDATA_CM3_MAC       ),


//to cm3_mac_1, ok
   .HSEL6      (HSEL_CM3_MAC_1         ),
   .HREADYOUT6 (HREADYOUT_CM3_MAC_1    ),
   .HRESP6     (HRESP_CM3_MAC_1        ),
   .HRDATA6    (HRDATA_CM3_MAC_1       ),


//to cm3_log, ok
   .HSEL7      (HSEL_CM3_LOG            ),
   .HREADYOUT7 (HREADYOUT_CM3_LOG      ),
   .HRESP7     (HRESP_CM3_LOG          ),
   .HRDATA7    (HRDATA_CM3_LOG         ),



   .HREADYOUT  (HREADYS    ), //to master, to itself, to every slave
   .HRESP      (HRESPS     ), // !1bit to master
   .HRDATA     (HRDATAS    )  //to master 
);

//systembus ahb->sram
wire [31:0] SRAMRDATA_S, SRAMWDATA_S;
wire [3:0]  SRAMWEN_S;
wire [13:0] SRAMADDR_S;
cmsdk_ahb_to_sram 
#(
   .AW (16)
)
u_cmsdk_ahb_to_sram_s(
   .HCLK      (HCLK               ),
   .HRESETn   (HRESETn            ),

   .HSEL      (HSEL_RAM           ),
   .HREADY    (HREADYS            ),
   .HTRANS    (HTRANSS            ),
   .HSIZE     (HSIZES             ),
   .HWRITE    (HWRITES            ),
   .HADDR     (HADDRS[15:0]       ),
   .HWDATA    (HWDATAS            ),       //no write happens
   .HREADYOUT (HREADYOUT_RAM_S    ),
   .HRESP     (HRESP_RAM_S        ),
   .HRDATA    (HRDATA_RAM_S       ),

   .SRAMRDATA (SRAMRDATA_S        ), //32bit
   .SRAMADDR  (SRAMADDR_S         ), //ADW = 14
   .SRAMWEN   (SRAMWEN_S          ), //4bit
   .SRAMWDATA (SRAMWDATA_S        ), //32bit 
   .SRAMCS    (SRAMCS_S           )  //cs
);

//sram for system bus
cmsdk_fpga_sram 
#(
   .AW       (14       ),      //64kb
   .MEMFILE  (""       )
)
u_cmsdk_fpga_sram_s(
   .CLK   (HCLK        ),
   .ADDR  (SRAMADDR_S  ),
   .WDATA (SRAMWDATA_S ),
   .WREN  (SRAMWEN_S   ),
   .CS    (SRAMCS_S    ),
   .RDATA (SRAMRDATA_S )
);


//APB subsystem
//no system ctrl block
  //---------------------------------------
apb_subsystem u_apb_subsystem (
  .HCLK            (HCLK),    // Clock
  .HRESETn         (HRESETn), // Reset
  .HSEL            (HSEL_APB),

//AHB interface
  .HADDR           (HADDRS[14:0]), //15bit up to 8 slaves
  .HTRANS          (HTRANSS),
  .HSIZE           (HSIZES),
  .HWRITE          (HWRITES),
  .HNONSEC         (1'b1),       //not use
  .HPROT           (7'b0),       //not use
  .HREADY          (HREADYS),
  .HWDATA          (HWDATAS),

  .HREADYOUT       (HREADYOUT_APB),
  .HRDATA          (HRDATA_APB),  
  .HRESP           (HRESP_APB),  //one bit 
//----------------------
  .PORT0_IN        (PORT0_IN),
  .PORT0_OUT       (PORT0_OUT),
  .PORT0_EN        (PORT0_EN),

  .PORT1_IN        (PORT1_IN),
  .PORT1_OUT       (PORT1_OUT),
  .PORT1_EN        (PORT1_EN),
  
  .TIMER0_IN       (TIMER0_IN),
  .TIMER1_IN       (TIMER1_IN),
  
  .UART0_RXD       (UART0_RXD),
  .UART0_TXD       (UART0_TXD),
  .UART0_TXEN      (UART0_TXEN),
  .UART0_BAUDTICK  (UART0_BAUDTICK),
  
  .Gpio0_IRQ       (Gpio0_IRQ),
  .Gpio1_IRQ       (Gpio1_IRQ),
  .Timer0_IRQ      (Timer0_IRQ),
  .Timer1_IRQ      (Timer1_IRQ),  
  .Uart0_TxIRQ     (Uart0_TxIRQ),
  .Uart0_RxIRQ     (Uart0_RxIRQ)
  );


//default slave ok
cmsdk_ahb_default_slave u_cmsdk_ahb_default_slave_s(
   .HCLK      (HCLK                 ), 
   .HRESETn   (HRESETn              ),

   .HSEL      (HSEL_DefSlave_S      ),
   .HTRANS    (HTRANSS              ),
   .HREADY    (HREADYS              ),
   .HREADYOUT (HREADYOUT_DefSlave_S ),
   .HRESP     (HRESP_DefSlave_S     )    //one bit
);

//cm3_adc
cm3_adc u_cm3_adc(
   .hclk     (HCLK          ),
   .rst_n    (HRESETn       ),
   .hready_i (HREADYS       ),
   .hsel     (HSEL_CM3_ADC  ),
   .hwrite   (HWRITES       ),
   .htrans   (HTRANSS       ),
   .haddr    (HADDRS[15:0]  ),
   .hwdata   (HWDATAS       ),

   .hresp    (HRESP_CM3_ADC ),
   .hready_o (HREADYOUT_CM3_ADC ),
   .hrdata   (HRDATA_CM3_ADC),
   .vp       (VP            ),
   .vn       (VN            ),
   .int      (CM3_ADC_INT   )
);

//cm3_fft
cm3_fft u_cm3_fft(
   .hclk     (HCLK            ),
   .rst_n    (HRESETn         ),

   .hready_i (HREADYS         ),
   .hsel     (HSEL_CM3_FFT    ),
   .hwrite   (HWRITES         ),
   .htrans   (HTRANSS         ),
   .haddr    (HADDRS[15:0]    ),
   .hwdata   (HWDATAS         ),

   .hresp    (HRESP_CM3_FFT    ),
   .hready_o (HREADYOUT_CM3_FFT),
   .hrdata   (HRDATA_CM3_FFT   ),
   .int      (CM3_FFT_INT      )
);

//cm3_mac
cm3_mac u_cm3_mac(
   .hclk     (HCLK            ),
   .rst_n    (HRESETn         ),

   .hready_i (HREADYS         ),
   .hsel     (HSEL_CM3_MAC    ),
   .hwrite   (HWRITES         ),
   .htrans   (HTRANSS         ),
   .haddr    (HADDRS[15:0]    ),
   .hwdata   (HWDATAS         ),
   .hresp    (HRESP_CM3_MAC   ),
   .hready_o (HREADYOUT_CM3_MAC),
   .hrdata   (HRDATA_CM3_MAC  )
);

//cm3_mac_1
cm3_mac u_cm3_mac_1(
   .hclk     (HCLK              ),
   .rst_n    (HRESETn           ),

   .hready_i (HREADYS           ),
   .hsel     (HSEL_CM3_MAC_1    ),
   .hwrite   (HWRITES           ),
   .htrans   (HTRANSS           ),
   .haddr    (HADDRS[15:0]      ),
   .hwdata   (HWDATAS           ),
   .hresp    (HRESP_CM3_MAC_1   ),
   .hready_o (HREADYOUT_CM3_MAC_1),
   .hrdata   (HRDATA_CM3_MAC_1  )
);

//cm3_log
cm3_log u_cm3_log(
   .hclk     (HCLK             ),
   .rst_n    (HRESETn          ),

   .hready_i (HREADYS          ),
   .hsel     (HSEL_CM3_LOG     ),
   .hwrite   (HWRITES           ),
   .htrans   (HTRANSS           ),
   .haddr    (HADDRS[15:0]      ),
   .hwdata   (HWDATAS           ),
   .hresp    (HRESP_CM3_LOG     ),
   .hready_o (HREADYOUT_CM3_LOG ),
   .hrdata   (HRDATA_CM3_LOG    )
);







//===============================================================================//
//  Interrupt assignments                                                        //
//===============================================================================//

assign CM3_INTERRUPTS[0] = Gpio0_IRQ;
assign CM3_INTERRUPTS[1] = Gpio1_IRQ;
assign CM3_INTERRUPTS[2] = Timer0_IRQ;
assign CM3_INTERRUPTS[3] = Timer1_IRQ;
assign CM3_INTERRUPTS[4] = Uart0_TxIRQ;
assign CM3_INTERRUPTS[5] = Uart0_RxIRQ;
assign CM3_INTERRUPTS[6] = CM3_ADC_INT;
assign CM3_INTERRUPTS[7] = CM3_FFT_INT;

assign CM3_INTERRUPTS[239:8] = {233{1'b0}}; // unused


//


  //--------------------------------
  // System control - Only handle DBG powerup loop back
  //                  and automatic reset when LOCKUP
  sys_ctrl u_sys_ctrl (
   .FCLK           (FCLK),
   .PORESETn       (PORESETn),
   .CDBGPWRUPREQ   (CDBGPWRUPREQ),
   .CDBGPWRUPACK   (CDBGPWRUPACK),
   
   .LOCKUP         (LOCKUP),
   .LOCKUP_RESET_EN(1'b1),          //always reset when lockup
   .LOCKUPRESET    (LOCKUPRESET)
  );



endmodule