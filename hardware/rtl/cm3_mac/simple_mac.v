module simple_mac (

    input        clk,
    input        rst_n,


    input [31:0] data_a,
    input [31:0] data_b,
    input        data_a_valid,
    input        data_b_valid,
    input        clear,          //one cycle clear, after two cycles of  clear data_out = 0

    output [31:0] data_out,     //two cycle latency
    output        overflow

);



wire [31:0]  mul_result;

mul_float32 u_mul_float32 (
  .aclk(clk),                                  // input wire aclk
  .aresetn(rst_n),                            // input wire aresetn

  .s_axis_a_tvalid(data_a_valid),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(s_axis_a_tready),            // ignore this signal
  .s_axis_a_tdata(data_a),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_a_tlast(1'b0),              // input wire s_axis_a_tlast

  .s_axis_b_tvalid(data_b_valid),            // input wire s_axis_b_tvalid
  .s_axis_b_tready(s_axis_b_tready),            // ignore this signal
  .s_axis_b_tdata(data_b),              // input wire [31 : 0] s_axis_b_tdata
  .s_axis_b_tlast(1'b0),              // input wire s_axis_b_tlast

  .m_axis_result_tvalid(mul_valid),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(mul_ready_in),  // input wire m_axis_result_tready
  .m_axis_result_tdata(mul_result),    // output wire [31 : 0] m_axis_result_tdata

  .m_axis_result_tlast()    //  ignore this signal
);

wire acc_valid_in;
assign acc_valid_in = clear | mul_valid;

acc_float32 u_acc_float32 (
  .aclk(clk),                                   // input wire aclk
  .aresetn(rst_n),                              // input wire aresetn
  
  .s_axis_a_tvalid(acc_valid_in),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(mul_ready_in),            // output wire s_axis_a_tready
  .s_axis_a_tdata(mul_result),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_a_tlast(clear),                  // input wire s_axis_a_tlast

  .m_axis_result_tvalid(acc_valid),              // i know when this is valid,
  .m_axis_result_tready(1'b1),  // input wire m_axis_result_tready
  .m_axis_result_tdata(data_out),    // output wire [31 : 0] m_axis_result_tdata
  .m_axis_result_tuser(overflow),    // output wire [0 : 0] m_axis_result_tuser
  .m_axis_result_tlast(m_axis_result_tlast)    // ignore 
);


    
endmodule