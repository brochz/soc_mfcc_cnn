module cm3_log (
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

wire [31:0] data_a, data_log;
cm3_log_reg u_cm3_log_reg(
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
    .data_a_valid (data_a_valid ),
    .data_log     (data_log     ),
    .data_log_valide(data_log_valide)
);

ln_float32 u_ln_float32 (
  .aclk(hclk),                                  // input wire aclk
  .aresetn(rst_n),                            // input wire aresetn

  .s_axis_a_tvalid(data_a_valid),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(data_a),              // input wire [31 : 0] s_axis_a_tdata

  .m_axis_result_tvalid(data_log_valide),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(data_log)    // output wire [31 : 0] m_axis_result_tdata
);

endmodule