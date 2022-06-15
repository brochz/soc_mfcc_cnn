module fix2_flo_win_fft (
    input hclk,
    input rst_n,

    //data in 
    input [31:0] data_in,  
    input        valid_in, 
    output       ready_out,

    //data out
    output [31:0] data_out,
    output        valid_out,
    output        last,         //indicat one frame over(256 point not n_need)
    input         ready_in,

    //ctrl
    input         win,
    input [7:0]   n_need,  //read data number
    input [3:0]   scale
);

wire [31:0] ff_s_axis_a_tdata;
wire [31:0] ff_m_axis_result_tdata;
assign ff_s_axis_a_tdata = data_in << scale;

fix12_2_float32 u_fix12_2_float32 (
  .aclk(hclk),                                  // input wire aclk
  .aresetn(rst_n),                            // input wire aresetn

  .s_axis_a_tvalid(valid_in),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(ready_out),            // output wire s_axis_a_tready
  .s_axis_a_tdata(ff_s_axis_a_tdata),              // input wire [31 : 0] s_axis_a_tdata

  .m_axis_result_tvalid(ff_m_axis_result_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(ff_m_axis_result_tready),  // input wire m_axis_result_tready
  .m_axis_result_tdata(ff_m_axis_result_tdata)    // output wire [31 : 0] m_axis_result_tdata
);





win_fft u_win_fft(
    .hclk      (hclk      ),
    .rst_n     (rst_n     ),



    .data_in   (ff_m_axis_result_tdata   ),
    .valid_in  (ff_m_axis_result_tvalid  ),
    .ready_out (ff_m_axis_result_tready ),


    .data_out  (data_out  ),
    .valid_out (valid_out ),
    .last      (last      ),
    .ready_in  (ready_in  ),


    .win       (win       ),
    .n_need    (n_need    )
);



endmodule