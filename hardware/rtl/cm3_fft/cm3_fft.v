module cm3_fft (
    //Global Input
    input                           hclk, 
    input                           rst_n,
    // AHB Bus Interface
    input                           hready_i,
    input                           hsel,  
    input                           hwrite,
    input  [1:0]                    htrans,
    input  [15:0]                   haddr,
    input  [31:0]                   hwdata, 


    output                          hresp,
    output                          hready_o,
    output [31:0]                   hrdata,    

    //int
    output        int
);

wire [31:0] win_fft_data_in, win_fft_data_out;
wire win_fft_valid_in, win_fft_ready_out, win_fft_valid_out, win_fft_ready_in, win_fft_win;
wire [7:0] win_fft_n_need;
wire [3:0] scale;

cm3_fft_reg u_cm3_fft_reg(
    .hclk              (hclk              ),
    .rst_n             (rst_n             ),

    .hready_i          (hready_i          ),
    .hsel              (hsel              ),
    .hwrite            (hwrite            ),
    .htrans            (htrans            ),
    .haddr             (haddr             ),
    .hwdata            (hwdata            ),
    .hresp             (hresp             ),
    .hready_o          (hready_o          ),
    .hrdata            (hrdata            ),


    .win_fft_data_in   (win_fft_data_in   ),
    .win_fft_valid_in  (win_fft_valid_in  ),
    .win_fft_ready_out (win_fft_ready_out ),
    .win_fft_data_out  (win_fft_data_out  ),
    .win_fft_valid_out (win_fft_valid_out ),
    .win_fft_ready_in  (win_fft_ready_in  ),
    .win_fft_win       (win_fft_win       ),
    .win_fft_n_need    (win_fft_n_need    ),
    .scale             (scale             ),
    .int               (int               )
);



fix2_flo_win_fft u_fix2_flo_win_fft(
    .hclk      (hclk      ),
    .rst_n     (rst_n     ),

    .data_in   (win_fft_data_in   ),
    .valid_in  (win_fft_valid_in  ),
    .ready_out (win_fft_ready_out ),
    
    .data_out  (win_fft_data_out  ),
    .valid_out (win_fft_valid_out ),
    .last      (last      ),  //for debug
    .ready_in  (win_fft_ready_in  ),

    .win       (win_fft_win       ),
    .n_need    (win_fft_n_need    ),
    .scale     (scale)
);


    
endmodule