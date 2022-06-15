initial begin
    //test TC9012 mode
    wait(rst_n);
    write_reg(32'h0000_0000, 32'h0000_0001);  //TC9012 mode
    write_reg(32'h0000_0008, 32'h0000_0003);  //enable IE
    write_reg(32'h0000_0014, 32'h0000_00f0);  //send data
    write_reg(32'h0000_0004, 32'h0000_0001);  //start send 
    
    #(IR_CLK_PERIOD*110000*3);
    write_reg(32'h0000_0004, 32'h0000_0000);  //stop send 

    //test NEC mode
    #(IR_CLK_PERIOD*110000*3);
    write_reg(32'h0000_0000, 32'h0000_0000);  //NEC mode
    write_reg(32'h0000_0014, 32'h0000_0088);  //send data
    write_reg(32'h0000_0004, 32'h0000_0001);  //start send 
    #(IR_CLK_PERIOD*110000*3);
    write_reg(32'h0000_0004, 32'h0000_0000);  //stop send 


 

    //test NEC mode single frame
    wait(~ir_tx1.ir_tx_busy);

    write_reg(32'h0000_0000, 32'h0000_0000);  //NEC mode
    write_reg(32'h0000_0004, 32'h0000_0001);  //start send 
    #(IR_CLK_PERIOD*2);
    write_reg(32'h0000_0004, 32'h0000_0000);  //stop send 
    #(IR_CLK_PERIOD*110000*3);
    $finish;
end