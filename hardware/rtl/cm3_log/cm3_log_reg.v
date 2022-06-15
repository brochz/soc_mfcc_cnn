
//this module contains no interrupt
module cm3_log_reg (
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
    output                          data_a_valid,
    input [31:0]                    data_log,
    input                           data_log_valide
);
    
//0x0000 -> data_a  WO
//0x0004 <- data_b  RO

reg [15:0]       addr;
reg              hwr;      

//===============================================================================//
// Wire Declaration                                                              //
//===============================================================================//
wire        reg_00_wr     ;

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
assign data_a_valid = reg_00_wr;

assign data_a = hwdata;



reg [31:0] result_buffer;
wire [31:0] result_buffer_next;

reg        result_valid;
wire       result_valid_next;
always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        result_valid <= 1'b1;   //avoid first read never valid
    end else begin
        result_valid <= result_valid_next;
    end
end
assign result_valid_next =  reg_00_wr? 1'b0 : data_log_valide|result_valid ;

always @(posedge hclk or negedge rst_n) begin
    if (~rst_n) begin
        result_buffer <= 32'b0;   //avoid first read never valid
    end else begin
        result_buffer <= result_buffer_next;
    end
end
assign result_buffer_next = data_log_valide? data_log: result_buffer;

assign hrdata = result_buffer; //only one output data, no need mask

assign hready_o = result_valid;
assign hresp    = 1'b0;
endmodule