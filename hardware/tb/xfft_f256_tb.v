`timescale 1ns/100ps
module xfft_f256_tb ;


parameter CLK_PERIOD = 20 ;
parameter N = 256;
parameter FILE_NAME = "float_256_fs100_f5.mem";
parameter OUTPUT_FILE_NAME = "float_256_fs100_f5_out.txt";
reg [7:0] PAT;


reg [31:0] samples [N-1:0];
reg clk, rst_n;
wire [63:0] data_in;
reg valid_in;
reg  last_in;
reg m_axis_data_tready;
wire [63:0] data_out;






xfft_f256 dut (
    .aclk(clk),                                                // input wire aclk
    .aresetn(rst_n),                                          // input wire aresetn

    .s_axis_config_tdata({23'b0,1'b1}),                  // input wire [23 : 0] s_axis_config_tdata
    .s_axis_config_tvalid(1'b1),                         // input wire s_axis_config_tvalid
    .s_axis_config_tready(s_axis_config_tready),                // output wire s_axis_config_tready

    .s_axis_data_tdata(data_in),                      // input wire [63 : 0] s_axis_data_tdata
    .s_axis_data_tvalid(valid_in),                    // input wire s_axis_data_tvalid
    .s_axis_data_tready(s_axis_data_tready),                    // output wire s_axis_data_tready
    .s_axis_data_tlast(last_in),                      // input wire s_axis_data_tlast

    .m_axis_data_tdata(data_out),                      // output wire [63 : 0] m_axis_data_tdata
    .m_axis_data_tvalid(m_axis_data_tvalid),                    // output wire m_axis_data_tvalid
    .m_axis_data_tready(m_axis_data_tready),                    // input wire m_axis_data_tready

    //ignore 
    .m_axis_data_tlast(m_axis_data_tlast),                      // output wire m_axis_data_tlast
    .event_frame_started(event_frame_started),                  // output wire event_frame_started
    .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
    .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
    .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
    .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
    .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
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
    last_in = 1'b0;
    m_axis_data_tready = 1'b1;
    PAT = 8'b0;
    $readmemb(FILE_NAME, samples); //
    #100;
    rst_n = 1'b1;
end

//one frame test
integer handler;
integer i = 0;
integer j = 0;
assign data_in = {32'b0, samples[i]};

initial begin
    handler = $fopen(OUTPUT_FILE_NAME);
    wait(rst_n);
    repeat(3) @(posedge clk);

    while(j<100) begin
        //give data 
        i = 0;
        valid_in = 1;
        while (i < N-1) begin
            @(posedge clk) begin    
                if (s_axis_data_tready) i = i + 1;
                if(i==N-1) last_in = 1;
            end
        end
        @(posedge clk) begin
            last_in = 0;
            valid_in = 0;
        end
    
        $fdisplay(handler, "REAL,            IMAGE");
    
        //gather output data
        while (i != 0) begin
            @(posedge clk) begin
                if(m_axis_data_tvalid) begin
                    $fdisplay(handler, "%b, %b", data_out[31:0], data_out[63:32]);
                end
                if(m_axis_data_tlast) i = 0;
            end
        end
        
        j = j + 1;
    end
    $fclose(handler);
    repeat(1000) @(posedge clk);
    PAT = PAT + 1; //PAT 1 TEST END.
    $finish;
end








initial begin
    wait(PAT==1);

    //
    m_axis_data_tready = 0;
    //give data 
    i = 0;
    valid_in = 1;
    while (i < N-1) begin
        @(posedge clk) begin    
            if (s_axis_data_tready) i = i + 1;
            if(i==N-1) last_in = 1;
        end
    end
    @(posedge clk) begin
        last_in = 0;
        valid_in = 0;
    end

    //give data 
    i = 0;
    valid_in = 1;
    while (i < N-1) begin
        @(posedge clk) begin    
            if (s_axis_data_tready) i = i + 1;
            if(i==N-1) last_in = 1;
        end
    end
    @(posedge clk) begin
        last_in = 0;
        valid_in = 0;
    end
end





    
endmodule