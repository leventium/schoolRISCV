`timescale 1ns / 1ps

module tb_mem;

    reg clk;
    reg b, h, w, we, sign;
    reg [31:0] wdata, addr;
    wire [31:0] rdata;

    sr_mem dut (
        .clk        ( clk   ),
        .data_addr  ( addr  ),
        .write_data ( wdata ),
        .we         ( we    ),
        .sign       ( sign  ),
        .byte_w     ( b     ),
        .half_w     ( h     ),
        .word_w     ( w     ),
        .read_data  ( rdata )
    );

    initial begin
        { b, h, w } = 3'b001;
        we = 1;
        sign = 0;
        addr = 0;
        wdata = 0;
        clk = 0;
        #10;
        clk = 1;
        #10;
        clk = 0;

        #10;
        $write("mem[31:0] = %h\n", rdata);

        { b, h, w } = 3'b100;
        addr = 32'h00000004;
        wdata = 32'h000000fe;
        #10;
        clk = 1;
        #10;
        clk = 0;

        { b, h, w } = 3'b100;
        sign = 1;
        #10;
        $write("mem[31:0] = %h\n", rdata);
    end

endmodule
