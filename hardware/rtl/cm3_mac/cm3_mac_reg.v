
//this module contains no interrupt
module cm3_mac_reg (
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

    //simple mac control port

    output [31:0]                   data_a,
    output [31:0]                   data_b,
    output                          data_a_valid,
    output                          data_b_valid,
    input [31:0]                    data_mac,
    output                          clear
);
    
//0x0000 -> data_a  WO
//0x0004 -> data_b  WO
//0x0008 <- data_mac RO

reg [15:0]       addr;
reg              hwr;      
reg [31:0]       r_hrdata;

//===============================================================================//
// Wire Declaration                                                              //
//===============================================================================//
wire [31:0] iordata       ;
wire        reg_00_wr     ;
wire        reg_04_wr     ;

wire        reg_08_rd     ;

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
assign reg_08_rd = hrd & (haddr == 16'h0008); 

assign data_a_valid = reg_00_wr;
assign data_b_valid = reg_04_wr;

assign data_a = hwdata;
assign data_b = hwdata;

assign hrdata = data_mac; //only one output data, no need mask


//===============================================================================//
// clear acc                                                              //
//===============================================================================//
reg reg_08_rd_d1;
always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        reg_08_rd_d1 <= 1'b0;
    end
    else  begin
        reg_08_rd_d1 <= reg_08_rd;
    end

end

assign clear = reg_08_rd_d1;

//
assign hready_o = 1'b1;
assign hresp          = 1'b0;
endmodule