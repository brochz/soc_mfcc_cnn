module cm3_adc_reg (
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

    //xadc interface 
    input  [23:0]                   din,   //xadc conversion result
    input                           drdy_in, //data ready, only for one clk cycle
    output                          enable,
    output                          double,
    output [15:0]                   div,

    //int
    output                          int

);


//===============================================================================//
// Register Definition                                                           //
//===============================================================================//
reg  [31:0]     reg_00;   //cm3_adc Register: CFG
reg  [31:0]     reg_04;   //cm3_adc Register: DIV
wire [31:0]     reg_08;   //cm3_adc Register: DAT
reg  [31:0]     reg_0c;   //cm3_adc Register: INT

//===============================================================================//
//                   .                                                           //
//===============================================================================//

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
wire        reg_08_rd     ;
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
// assign reg_08_wr = hwr & (addr == 16'h0008);// 0x08 is read only
assign reg_0c_wr = hwr & (addr == 16'h000c);


assign reg_00_rd = hrd & (haddr == 16'h0000);
assign reg_04_rd = hrd & (haddr == 16'h0004);
assign reg_08_rd = hrd & (haddr == 16'h0008); 
assign reg_0c_rd = hrd & (haddr == 16'h000c);

//-------------------------------------------------------------------------------//
//  AHB read                                                                     //
//===============================================================================//

assign reg_08 = {4'b0,din[23:12], 4'b0, din[11:0]};
assign iordata = ({32{reg_00_rd}} & reg_00 )|
                 ({32{reg_04_rd}} & reg_04 )|
                 ({32{reg_08_rd}} & reg_08 )|   
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
        reg_00 <=  32'h0000_0000;
        reg_04 <=  32'h0000_0c34;
    end
    else begin
        if (reg_00_wr)  reg_00 <=  hwdata & 32'h0000_0007;
        if (reg_04_wr)  reg_04 <=  hwdata & 32'h0000_ffff;  //div bits
    end     
end

//-------------------------------------------------------------------------------//
// INT REG                                                        //
//===============================================================================//
wire [31:0] reg_0c_next;
always @(posedge hclk or negedge rst_n) begin
    if(~rst_n) begin
        reg_0c <= 32'b0;
    end else begin
        reg_0c <= reg_0c_next;
    end
end

assign reg_0c_next = ~reg_08_rd & (reg_0c_wr? {31'h0,(~hwdata[0] & reg_0c[0])}: {31'h0, drdy_in|reg_0c[0]});

assign int = reg_0c[0] & reg_00[2]; //reg_00[2], is int enable

//-------------------------------------------------------------------------------//
//  Give  xadc  control siganl                                                  //
//===============================================================================//
assign enable = reg_00[0];
assign double = reg_00[1];
assign div    = reg_04[15:0];

//AHB response and ready
assign hready_o       = 1'b1;
assign hresp          = 1'b0;

endmodule