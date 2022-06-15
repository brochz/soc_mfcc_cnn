module win_fft (
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
    input [7:0]   n_need  //read data number
);

wire [31:0] win_data_out;
wire [31:0] fft_data_in;
wire        win_valid_out;
wire        fft_valid_in;
wire        win_ready_in;
wire        win_ready_out;
wire        fft_ready_out;

wire        fft_valid_out;
wire        fft_ready_in;


reg [7:0]   counter;
//choose win or not
assign fft_data_in = win? win_data_out : data_in;
assign fft_valid_in = win? win_valid_out : valid_in;
assign win_ready_in = win? fft_ready_out : 1'b0;
assign ready_out = win? win_ready_out: fft_ready_out;


hannwin_f256 u_hannwin_f256(
    .hclk      (hclk          ),
    .rst_n     (rst_n         ),
    .data_in   (data_in       ),
    .valid_in  (valid_in      ),
    .ready_out (win_ready_out ),

    .data_out  (win_data_out  ),
    .valid_out (win_valid_out ),
    .last      (              ),
    .ready_in  (win_ready_in  )

);


fft_power u_fft_power(
    .hclk      (hclk          ),
    .rst_n     (rst_n         ),
    .data_in   (fft_data_in   ),
    .valid_in  (fft_valid_in  ),
    .ready_out (fft_ready_out ),
    .data_out  (data_out      ),

    .valid_out (fft_valid_out ),
    .last      (last          ),
    .ready_in  (fft_ready_in  )
);


//flush data in fft buffer

wire [7:0] counter_next;
always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        counter <= 8'b0;
    end else begin
        counter <= counter_next;
    end
end

assign counter_next = fft_valid_out & fft_ready_in ?
                      counter + 1:
                      counter;

assign fft_ready_in = counter < n_need ? ready_in : 1'b1 ; 


assign valid_out = fft_valid_out & counter<n_need;


    
endmodule