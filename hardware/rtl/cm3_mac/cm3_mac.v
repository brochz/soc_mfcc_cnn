module cm3_mac (
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
    output [31:0]                   hrdata
);

wire [31:0] data_a, data_b, data_mac;
cm3_mac_reg u_cm3_mac_reg(
    .hclk         (hclk         ),
    .rst_n        (rst_n        ),
    .hready_i     (hready_i     ),
    .hsel         (hsel         ),
    .hwrite       (hwrite       ),
    .htrans       (htrans       ),
    .haddr        (haddr        ),
    .hwdata       (hwdata       ),
    .hresp        (hresp        ),
    .hready_o     (hready_o     ),
    .hrdata       (hrdata       ),

    .data_a       (data_a       ),
    .data_b       (data_b       ),
    .data_a_valid (data_a_valid ),
    .data_b_valid (data_b_valid ),
    .data_mac     (data_mac     ),
    .clear        (clear        )
);


simple_mac u_simple_mac(
    .clk           (hclk           ),
    .rst_n         (rst_n         ),

    .data_a        (data_a        ),
    .data_b        (data_b        ),

    .data_a_valid (data_a_valid ),
    .data_b_valid (data_b_valid ),

    .clear         (clear         ),
    .data_out      (data_mac      ),
    .overflow      (overflow      )    //ignore first.....
);



endmodule