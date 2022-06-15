//calculate fft power spectrum
module fft_power (
    input hclk,
    input rst_n,

    //data in 
    input [31:0] data_in        ,
    input        valid_in,
    output       ready_out,

    //data out
    output [31:0] data_out,
    output        valid_out,
    output        last,         //indicat one frame over
    input         ready_in

    
    
);

//-------------------------------------------------------------------------------//
//                               xfft instantiation                              //
//===============================================================================//
wire [63:0] xfft_data;
wire        xfft_valid;
wire        xfft_ready_in;
wire        xfft_last;

xfft_f256 u0_xfft_f256 (
    .aclk(hclk),                                                // input wire aclk
    .aresetn(rst_n),                                          // input wire aresetn

    //fixed value
    .s_axis_config_tdata({23'b0,1'b1}),                      // only perform forward fft
    .s_axis_config_tvalid(1'b1),                             // input wire s_axis_config_tvalid
    .s_axis_config_tready(),                                 // output wire s_axis_config_tready


    .s_axis_data_tdata({32'b0, data_in}),                      // input wire [63 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(valid_in),                    // input wire s_axis_data_tvalid
    .s_axis_data_tready(ready_out),                    // output wire s_axis_data_tready
    .s_axis_data_tlast(1'b0),                                   // flow mode


    .m_axis_data_tdata(xfft_data),                      // output wire [63 : 0] m_axis_data_tdata
    .m_axis_data_tvalid(xfft_valid),                    // output wire m_axis_data_tvalid
    .m_axis_data_tready(xfft_ready_in),                 // input wire m_axis_data_tready
    .m_axis_data_tlast(xfft_last),                      // output wire m_axis_data_tlast

    //ignore all of those signal
    .event_frame_started(),                  // output wire event_frame_started
    .event_tlast_unexpected(),            // output wire event_tlast_unexpected
    .event_tlast_missing(),                  // output wire event_tlast_missing
    .event_status_channel_halt(),      // output wire event_status_channel_halt
    .event_data_in_channel_halt(),    // output wire event_data_in_channel_halt
    .event_data_out_channel_halt()  // output wire event_data_out_channel_halt
);

//-------------------------------------------------------------------------------//
//                               mul_1 instantiation                             //
//===============================================================================//
wire mul_1_ready_oa;
wire mul_1_ready_ob;
wire mul_1_valid_o;
wire mul_1_ready_in;
wire mul_1_last_o;
wire [31:0] mul_1_data_o;

mul_float32 u0_mul_float32 (
    .aclk(hclk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn


    .s_axis_a_tvalid(xfft_valid),             // input wire s_axis_a_tvalid
    .s_axis_a_tready(mul_1_ready_oa),            // output wire s_axis_a_tready
    .s_axis_a_tdata(xfft_data[31:0]),              // input wire [31 : 0] s_axis_a_tdata
    .s_axis_a_tlast(xfft_last),              // input wire s_axis_a_tlast

    .s_axis_b_tvalid(xfft_valid),            // input wire s_axis_b_tvalid
    .s_axis_b_tready(mul_1_ready_ob),                      // output wire s_axis_b_tready
    .s_axis_b_tdata(xfft_data[31:0]),              // input wire [31 : 0] s_axis_b_tdata
    .s_axis_b_tlast(xfft_last),              // input wire s_axis_b_tlast

    .m_axis_result_tvalid(mul_1_valid_o),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(mul_1_ready_in),  // input wire m_axis_result_tready
    .m_axis_result_tdata(mul_1_data_o),    // output wire [31 : 0] m_axis_result_tdata
    .m_axis_result_tlast(mul_1_last_o)    // output wire m_axis_result_tlast
);


//-------------------------------------------------------------------------------//
//                               mul_2 instantiation                             //
//===============================================================================//
wire mul_2_ready_oa;
wire mul_2_ready_ob;
wire mul_2_valid_o;
wire mul_2_ready_in;
wire mul_2_last_o;
wire [31:0] mul_2_data_o;

mul_float32 u1_mul_float32 (
    .aclk(hclk),                                  // input wire aclk
    .aresetn(rst_n),                            // input wire aresetn


    .s_axis_a_tvalid(xfft_valid),             // input wire s_axis_a_tvalid
    .s_axis_a_tready(mul_2_ready_oa),            // output wire s_axis_a_tready
    .s_axis_a_tdata(xfft_data[63:32]),              // input wire [31 : 0] s_axis_a_tdata
    .s_axis_a_tlast(xfft_last),              // input wire s_axis_a_tlast

    .s_axis_b_tvalid(xfft_valid),            // input wire s_axis_b_tvalid
    .s_axis_b_tready(mul_2_ready_ob),                      // output wire s_axis_b_tready
    .s_axis_b_tdata(xfft_data[63:32]),              // input wire [31 : 0] s_axis_b_tdata
    .s_axis_b_tlast(xfft_last),              // input wire s_axis_b_tlast

    .m_axis_result_tvalid(mul_2_valid_o),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(mul_2_ready_in),  // input wire m_axis_result_tready
    .m_axis_result_tdata(mul_2_data_o),    // output wire [31 : 0] m_axis_result_tdata
    .m_axis_result_tlast(mul_2_last_o)    // output wire m_axis_result_tlast
);

assign xfft_ready_in = mul_1_ready_oa & mul_2_ready_oa & mul_1_ready_ob & mul_2_ready_ob;
//-------------------------------------------------------------------------------//
//                               add  instantiation                              //
//===============================================================================//

add_float32 u0_add_float32 (
  .aclk(hclk),                                  // input wire aclk
  .aresetn(rst_n),                            // input wire aresetn


  .s_axis_a_tvalid(mul_1_valid_o),             // input wire s_axis_a_tvalid
  .s_axis_a_tready(mul_1_ready_in),            // output wire s_axis_a_tready
  .s_axis_a_tdata(mul_1_data_o),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_a_tlast(mul_1_last_o),              // input wire s_axis_a_tlast

  .s_axis_b_tvalid(mul_2_valid_o),            // input wire s_axis_b_tvalid
  .s_axis_b_tready(mul_2_ready_in),            // output wire s_axis_b_tready
  .s_axis_b_tdata(mul_2_data_o),              // input wire [31 : 0] s_axis_b_tdata
  .s_axis_b_tlast(mul_2_last_o),              // input wire s_axis_b_tlast


  .m_axis_result_tvalid(valid_out),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(ready_in),  // input wire m_axis_result_tready
  .m_axis_result_tdata(data_out),    // output wire [31 : 0] m_axis_result_tdata
  .m_axis_result_tlast(last)    // output wire m_axis_result_tlast
);






endmodule