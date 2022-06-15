`timescale 1ns/100ps

module cm3_fft_tb;

parameter HCLK_PERIOD = 20;
parameter N = 256;
parameter FILE_NAME = "float_256_fs100_f5.mem";
parameter OUTPUT_FILE_NAME = "win_fft_out.txt";
reg [7:0] PAT;


reg hclk;
reg rst_n;
reg hready_i;
reg hwrite;
reg hsel;
reg [1:0] htrans;
reg [31:0] haddr;
reg [31:0] hwdata;
wire [31:0] hrdata;
reg [31:0] samples [N-1:0];
reg [31:0] dout;
wire hready_o;
wire hresp;
wire int;

`include "ahb_task.v"

cm3_fft u_cm3_fft(
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
    .int      (int      )
);

always #(HCLK_PERIOD/2) hclk   = ~hclk;


initial begin

    hclk     =  0;
    rst_n    =  0;
    hready_i =  1;
    hwrite   =  0;
    haddr    =  0;
    hwdata   =  0;
    htrans   =  0;
    hsel     =  1;
    dout     =  0;
    $readmemb(FILE_NAME, samples); //
    repeat(2) @(posedge hclk);
    rst_n =  1;
end




//one frame test
integer handler;
integer i = 0;




initial begin
    wait(rst_n);
    $display("test start at %t\n", $time);
    write_reg(32'h0000_0000, 32'h0000_fff3); 
    read_cmp(32'h0000_0000, 32'h0000_fff3);
    write_reg(32'h0000_0004, 32'h0000_0001);  
    read_cmp(32'h0000_0004, 32'h0000_0001);  


    $display("======================================\n");
    $display("======================================\n");
    $display("======================================\n");
    $display("!!!!!!!!!!!!PASS!!!!!!!!!!!!!!!!!!!!! \n");
    $display("======================================\n");
    $display("======================================\n");
    $display("======================================\n");
    $finish;
end



initial begin
    wait(error);
    $display("======================================\n");
    $display("======================================\n");
    $display("======================================\n");
    $display("!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!\n ");
    $display("======================================\n");
    $display("======================================\n");
    $display("======================================\n");
    $finish;
end





// initial begin
//     PAT = 0;
//     handler = $fopen(OUTPUT_FILE_NAME);
//     wait(rst_n);
//     repeat(2) @(posedge hclk);
//     write_reg(32'h0, 32'h81<<8 | 32'h3);
//     write_reg(32'h4, 32'h1);

//     for (i = 0; i < N; i = i+1) begin
//         write_reg(32'h8, samples[i]);
//     end

//     wait(int);

//     for (i = 0; i < N/2 + 1; i = i+1) begin
//         read_reg(32'hc);
//     end
    
//     repeat(100) @(posedge hclk);
//     for (i = 0; i < N; i = i + 1) begin
//         write_reg(32'h8, samples[i]);
//     end

//     wait(int);

//     for (i = 0; i < N/2 + 1; i = i+1) begin
//         read_reg(32'hc);
//     end

//     $fclose(handler);
//     repeat(1000) @(posedge hclk);
//     PAT = PAT + 1; //PAT 1 TEST END.
//     $finish;
// end




endmodule