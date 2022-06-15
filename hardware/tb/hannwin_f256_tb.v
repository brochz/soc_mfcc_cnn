`timescale 1ns/100ps
module hannwin_f256_tb;

parameter CLK_PERIOD = 20 ;
parameter N = 256;
parameter FILE_NAME = "float_256_fs100_f5.mem";
parameter OUTPUT_FILE_NAME = "C:/Users/zhang/OneDrive/armCup/first/hardware/tb/hannwin_f256_out.txt";
reg [7:0] PAT;

reg [31:0] samples [N-1:0];
reg clk, rst_n;
reg valid_in;
reg ready_in;

wire [31:0] data_in, data_out;
wire ready_out;
wire valid_out;
wire last;


hannwin_f256  u_hannwin_f256(
    .hclk      (clk       ),
    .rst_n     (rst_n     ),
    .data_in   (data_in   ),
    .valid_in  (valid_in  ),
    .ready_out (ready_out ),
    .data_out  (data_out  ),
    .valid_out (valid_out ),
    .last      (last      ),
    .ready_in  (ready_in  )
);





//clk 
always #(CLK_PERIOD/2) clk   = ~clk;
initial begin
    clk = 0;
end


//initial device
initial begin
    rst_n = 1'b0;
    valid_in = 1'b0;
    ready_in = 1'b1;
    PAT = 8'b0;
    $readmemb(FILE_NAME, samples); //
    #100;
    @(posedge clk) begin
        rst_n = 1'b1;
    end
end



//one frame test
integer handler;
integer i = 0;
assign data_in = samples[i];

initial begin
    wait(rst_n);
    repeat(2) @(posedge clk);

    //give data 
    i = 0;
    valid_in = 1;
    while (i < N-1) begin
        @(posedge clk) begin    
            if (ready_out) i = i + 1;
        end
    end
    @(posedge clk) begin
        valid_in = 0;
    end
end

integer j = 0;
initial begin
    handler = $fopen(OUTPUT_FILE_NAME);
    ready_in = 1;
    //gather output data
    while (j == 0) begin
        @(posedge clk) begin
            if(valid_out) begin
                $fdisplay(handler, "%b", data_out[31:0]);
            end
            if(last) j = 1;
        end
    end

    $fclose(handler);
    repeat(1000) @(posedge clk);
    PAT = PAT + 1; //PAT 1 TEST END.
    $finish;
end




endmodule
