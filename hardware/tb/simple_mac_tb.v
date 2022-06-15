`timescale 1ns/100ps
module simple_mac_tb ;


parameter CLK_PERIOD = 20 ;
reg clk, rst_n;
reg s_axis_a_tvalid, s_axis_b_tvalid;
reg [31:0] s_axis_a_tdata, s_axis_b_tdata;
reg s_axis_a_tlast, s_axis_b_tlast;
reg m_axis_result_tready;
wire [31:0] m_axis_result_tdata;
reg  clear;

simple_mac u_simple_mac(
    .clk           (clk           ),
    .rst_n         (rst_n         ),
    
    .data_a        (s_axis_a_tdata        ),
    .data_b        (s_axis_b_tdata        ),
    .data_a_valide (s_axis_a_tvalid ),
    .data_b_valide (s_axis_b_tvalid ),
    .clear         (clear         ),
    .data_out      (m_axis_result_tdata      ),
    .overflow      (overflow      )
);



//clk 
always #(CLK_PERIOD/2) clk   = ~clk;
initial begin
    clk = 0;
end


//initial device
initial begin
    rst_n = 0;
    clear = 0;
    s_axis_a_tdata = 0;
    s_axis_b_tdata = 0;
    s_axis_a_tvalid = 0;
    s_axis_b_tvalid = 0;
    s_axis_a_tlast = 0;
    s_axis_b_tlast = 0;
    m_axis_result_tready = 1;
    repeat(10) @(posedge clk);
    rst_n = 1;
    repeat(2) @(posedge clk);
    //send a
    s_axis_a_tdata = 32'b00111110100111100011011101111010;
    s_axis_a_tvalid = 1;
    @(posedge clk);
    s_axis_a_tdata = 0;
    s_axis_a_tvalid = 0;
    @(posedge clk);
    @(posedge clk);
    s_axis_b_tdata = 32'b00111110100111100011011101111010;
    s_axis_b_tvalid = 1;
    @(posedge clk);
    s_axis_b_tdata = 0;
    s_axis_b_tvalid = 0;



    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    s_axis_a_tdata = 32'b00111110100111100011011101111010;
    s_axis_a_tvalid = 1;
    @(posedge clk);
    s_axis_a_tdata = 0;
    s_axis_a_tvalid = 0;
    @(posedge clk);
    @(posedge clk);

    s_axis_b_tdata = 32'b00111110100111100011011101111010;
    s_axis_b_tvalid = 1;
    @(posedge clk);
    s_axis_b_tdata = 0;
    s_axis_b_tvalid = 0;
    repeat(10) @(posedge clk);
    clear = 1;
    @(posedge clk);
    clear = 0;


    repeat(1) @(posedge clk);
    //send a
    s_axis_a_tdata = 32'b00111110100111100011011101111010;
    s_axis_a_tvalid = 1;
    @(posedge clk);
    s_axis_a_tdata = 0;
    s_axis_a_tvalid = 0;
    @(posedge clk);
    @(posedge clk);

    s_axis_b_tdata = 32'b00111110100111100011011101111010;
    s_axis_b_tvalid = 1;
    @(posedge clk);
    s_axis_b_tdata = 0;
    s_axis_b_tvalid = 0;



    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    s_axis_a_tdata = 32'b00111110100111100011011101111010;
    s_axis_a_tvalid = 1;
    @(posedge clk);
    s_axis_a_tdata = 0;
    s_axis_a_tvalid = 0;
    @(posedge clk);
    @(posedge clk);

    s_axis_b_tdata = 32'b00111110100111100011011101111010;
    s_axis_b_tvalid = 1;
    @(posedge clk);
    s_axis_b_tdata = 0;
    s_axis_b_tvalid = 0;
    repeat(10) @(posedge clk);
    clear = 1;
    @(posedge clk);
    clear = 0;
    $finish;
end


endmodule