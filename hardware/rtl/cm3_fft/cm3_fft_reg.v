module cm3_fft_reg (
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

    //win_fft interface 
    //fft data in 
    output [31:0] win_fft_data_in,  
    output        win_fft_valid_in, 
    input         win_fft_ready_out,

    //fft data out
    input [31:0]  win_fft_data_out,
    input         win_fft_valid_out,
    output        win_fft_ready_in,

    //ctrl
    output        win_fft_win,
    output [7:0]  win_fft_n_need,  //read data number
    output [3:0]  scale,
    //int
    output        int

);


//===============================================================================//
// Register Definition                                                           //
//===============================================================================//
reg  [31:0]     reg_00;   //cm3_adc Register: CFG
reg  [31:0]     reg_04;   //cm3_adc Register: CTL
// wire [31:0]     reg_08;   //cm3_adc Register: DIN
wire [31:0]     reg_0c;   //cm3_adc Register: DOUT


reg [15:0]       addr;
reg              hwr;      
reg [31:0]       r_hrdata;


//===============================================================================//
// Wire Declaration                                                              //
//===============================================================================//
wire [31:0] iordata       ;
wire        reg_00_wr     ;
wire        reg_04_wr     ;
wire        reg_08_wr     ;
wire        reg_0c_wr     ;


wire        reg_00_rd     ;
wire        reg_04_rd     ;
// wire        reg_08_rd     ;
wire        reg_0c_rd     ;


wire        ahb_valid     ;
wire        hrd           ;


//===============================================================================//
//                              /\     ||    || ||====\                          //
//                             //\\    ||    || ||     |                         //
//                            //  \\   ||====|| ||====<                          //
//                           //====\\  ||    || ||     |                         //
//                          //      \\ ||    || ||====/                          //
//                                                                               //
//-------------------------------------------------------------------------------//
//                               AHB Bus Operation                               //
//===============================================================================//

assign ahb_valid = hready_i & hsel & htrans[1];

always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        addr <= 16'h0;
    end
    else if (ahb_valid) begin
        addr <= haddr[15:0];
    end
end

always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        hwr <= 1'b0;
    end
    else if (ahb_valid) begin
        hwr <= hwrite;
    end
    else begin
        hwr <= 1'b0;
    end
end

assign hrd = ahb_valid & (~hwrite);

assign reg_00_wr = hwr & (addr == 16'h0000);
assign reg_04_wr = hwr & (addr == 16'h0004);

assign reg_08_wr = hwr & (addr == 16'h0008);    
// assign reg_0c_wr = hwr & (addr == 16'h000c);

//!
assign reg_00_rd = hrd & (haddr == 16'h0000);
assign reg_04_rd = hrd & (haddr == 16'h0004);

// assign reg_08_rd = hrd & (haddr == 16'h0008); 
assign reg_0c_rd = hrd & (haddr == 16'h000c);

//-------------------------------------------------------------------------------//
//  AHB read                                                                     //
//===============================================================================//
assign reg_0c = win_fft_data_out;
assign win_fft_ready_in = reg_0c_rd;

assign iordata = ({32{reg_00_rd}} & reg_00 )|
                 ({32{reg_04_rd}} & reg_04 )|  
                 ({32{reg_0c_rd}} & reg_0c );
//put iordata to hrdata
assign hrdata = r_hrdata;
always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        r_hrdata <=  32'b0;
    end 
    else if (hrd) begin
        r_hrdata <=  iordata;
    end
    else begin
        r_hrdata <=  32'b0;
    end
end



//-------------------------------------------------------------------------------//
//  AHB write  & REG                                                             //
//===============================================================================//

always @(posedge hclk or negedge rst_n) begin
    if(~rst_n) begin
        reg_00 <=  32'h0000_ff00;
        reg_04 <=  32'h0000_0000;
    end
    else begin
        if (reg_00_wr)  reg_00 <=  hwdata & 32'h0000_fff3;
        if (reg_04_wr)  reg_04 <=  hwdata & 32'h0000_0001;  //div bits
    end     
end


assign win_fft_data_in = hwdata;
assign win_fft_valid_in = reg_08_wr & reg_04[0];  //enable ctrl


//-------------------------------------------------------------------------------//
// hready o handle                                                               //
// handle it next time...                                                        //
//===============================================================================//
assign hready_o       = 1'b1;
assign hresp          = 1'b0;


//-------------------------------------------------------------------------------//
// INT REG                                                                       //
//===============================================================================//


assign int = win_fft_valid_out & reg_00[1]; //reg_00[1], is int enable


//-------------------------------------------------------------------------------//
//  Give    control siganl                                                  //
//===============================================================================//
assign win_fft_win = reg_00[0];
assign win_fft_n_need = reg_00[15:8];
assign scale = reg_00[7:4];



endmodule