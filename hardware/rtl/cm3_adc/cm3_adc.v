module cm3_adc (
    //Global Input
    input                           hclk, 
    input                           rst_n,
    // AHB Bus Interface
    input                           hready_i,
    input                           hsel,  
    input                           hwrite,
    input  [1:0]                    htrans,
    input  [15:0]                   haddr,
    input  [31:0]                   hwdata,  
    output                          hresp,
    output                          hready_o,
    output [31:0]                   hrdata, 

    //adc input
    input                           vp,  
    input                           vn,

    //int
    output                          int  

);


wire [23:0] d;
wire [15:0] div;
wire        drdy;
wire        enable;
wire        double;

cm3_adc_reg u_cm3_adc_reg(
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
    .din      (d        ),
    .drdy_in  (drdy  ),
    .enable   (enable   ),
    .double   (double   ),
    .div      (div      ),
    .int      (int      )
);





xadc_wrapper u_xadc_wrapper(
    .hclk   (hclk   ),
    .rst_n  (rst_n  ),
    .enable (enable ),
    .double (double ),
    .div    (div    ),
    .vp     (vp     ),
    .vn     (vn     ),
    .dout   (d      ),
    .drdy   (drdy   )
);
  

endmodule



