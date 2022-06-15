`timescale 1ns/100ps
module ln_float32_tb ;


parameter CLK_PERIOD = 20 ;
reg clk, rst_n;
reg s_axis_a_tvalid;
reg [31:0] s_axis_a_tdata;

reg m_axis_result_tready;
wire [31:0] m_axis_result_tdata;

ln_float32 dut (
  .aclk(clk),                                  // input wire aclk
  .aresetn(rst_n),                            // input wire aresetn
  .s_axis_a_tvalid(s_axis_a_tvalid),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(s_axis_a_tdata),              // input wire [31 : 0] s_axis_a_tdata

  .m_axis_result_tvalid(m_axis_result_tvalid),  // output wire m_axis_result_tvalid
//  .m_axis_result_tready(m_axis_result_tready),  // input wire m_axis_result_tready
  .m_axis_result_tdata(m_axis_result_tdata)    // output wire [31 : 0] m_axis_result_tdata
);
//clk 
always #(CLK_PERIOD/2) clk   = ~clk;
initial begin
    clk = 0;
end


//initial device
initial begin
    rst_n = 0;
    m_axis_result_tready = 0;
    s_axis_a_tdata = 0;
    s_axis_a_tvalid = 0;
    repeat(10) @(posedge clk);
    rst_n = 1;
    repeat(10) @(posedge clk);
    s_axis_a_tdata = 32'b01000000001011011111100001010100;;
    s_axis_a_tvalid = 1;
    @(posedge clk);
    s_axis_a_tvalid = 0;
    repeat(1) @(posedge clk);
    m_axis_result_tready = 1;
    repeat(1) @(posedge clk);
    s_axis_a_tdata = 32'b01000001001011011111100001010100;;
    s_axis_a_tvalid = 1;
    @(posedge clk);
    s_axis_a_tvalid = 0;
    repeat(10) @(posedge clk);
    $finish;
end


endmodule