`timescale 1ns/100ps
module fix12_2_float32_tb;
  
parameter HCLK_PERIOD = 20;
reg hclk;


wire [31:0] s_axis_a_tdata;
wire [31:0] m_axis_result_tdata;
reg s_axis_a_tvalid;
reg rst_n;

fix12_2_float32 your_instance_name (
  .aclk(hclk),                                  // input wire aclk
  .aresetn(rst_n),                            // input wire aresetn
  .s_axis_a_tvalid(s_axis_a_tvalid),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(s_axis_a_tready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(s_axis_a_tdata),              // input wire [31 : 0] s_axis_a_tdata
  .m_axis_result_tvalid(m_axis_result_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(1'b1),  // input wire m_axis_result_tready
  .m_axis_result_tdata(m_axis_result_tdata)    // output wire [31 : 0] m_axis_result_tdata
);

always #(HCLK_PERIOD/2) hclk   = ~hclk;
integer i;
assign s_axis_a_tdata = i;
initial begin

    hclk     =  0;
    i = 0;
    s_axis_a_tvalid = 0;
    rst_n = 0;
    repeat(4) @(posedge hclk);
    rst_n = 1;
    repeat(4) @(posedge hclk);
     s_axis_a_tvalid = 1;
    i = 10000;
    repeat(20) @(posedge hclk);
    i = -10000;
    repeat(20) @(posedge hclk);
    $finish;
end




endmodule