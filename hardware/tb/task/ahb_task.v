

localparam  IDLE   = 2'b00;
localparam  NONSEQ = 2'b10;
localparam  SEQ    = 2'b11;
reg error=0;

task write_reg;

input   [31:0]  addr;
input   [31:0]  din ;
begin
    @(posedge hclk);
        htrans <= NONSEQ;
        haddr  <=  addr;
        hwrite <= 1'b1;
        hwdata <= 32'b0;
    @(posedge hclk);
        htrans <=  IDLE;
        haddr  <=  32'b0;
        hwrite <=  1'b0;
        hwdata <=  din;
    @(posedge hclk);
        htrans <=  IDLE;
        haddr  <= 32'b0;
        hwrite <=  1'b0;
        hwdata <=  32'b0;

end

endtask



task read_reg;
input    [31:0]  addr;

begin
    @(posedge hclk);
        htrans <= NONSEQ;
        haddr  <=  addr;
        hwrite <= 1'b0;
    @(posedge hclk);
        htrans <=  IDLE;
        haddr  <=  32'b0;
        hwrite <=  1'b0;
    @(posedge hclk);
        htrans <=  IDLE;
        haddr  <= 32'b0;
        hwrite <=  1'b0;
        // $fdisplay(handler, "%b", hrdata);

end

endtask

task read_cmp;

input [31:0] addr;
input [31:0] cmp_dat;

begin
    @(posedge hclk);
        htrans <=    NONSEQ;
        haddr  <=    addr;
    @(posedge hclk);
        htrans <=    IDLE;
        haddr  <=    32'b0;
    @(posedge hclk);
        $display("cmp_dat=%x, hrdata=%x\n", cmp_dat, hrdata);
        error <=  hrdata != cmp_dat;
end
endtask
