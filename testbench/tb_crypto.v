`timescale 1ns / 1ps

`define MAX_CYCLES 60

module tb_crypto;

task log(input [31:0] rs1, rs2, rs3);
    $write("rs1 - 0x%h  |  rs2 - 0x%h  |  rd - 0x%h\n", rs1, rs2, rs3);
endtask

integer cycle;

reg clk, reset;
reg [20:0] mode;
reg [31:0] rs1, rs2, rd;
reg i_valid, o_valid;
reg [3:0] imm;

riscv_crypto_fu_rv32 dut (
    .g_clk             ( clk      ),
    .g_resetn          ( reset    ),

    .valid             ( i_valid  ),
    .rs1               ( rs1      ),
    .rs2               ( rs2      ),
    .imm               ( imm      ),

    .op_lut4lo         ( mode[ 0] ),
    .op_lut4hi         ( mode[ 1] ),
    .op_lut4           ( mode[ 2] ),
    .op_saes32_encs    ( mode[ 3] ),
    .op_saes32_encsm   ( mode[ 4] ),
    .op_saes32_decs    ( mode[ 5] ),
    .op_saes32_decsm   ( mode[ 6] ),
    .op_ssha256_sig0   ( mode[ 7] ),
    .op_ssha256_sig1   ( mode[ 8] ),
    .op_ssha256_sum0   ( mode[ 9] ),
    .op_ssha256_sum1   ( mode[10] ),
    .op_ssha512_sum0r  ( mode[11] ),
    .op_ssha512_sum1r  ( mode[12] ),
    .op_ssha512_sig0l  ( mode[13] ),
    .op_ssha512_sig0h  ( mode[14] ),
    .op_ssha512_sig1l  ( mode[15] ),
    .op_ssha512_sig1h  ( mode[16] ),
    .op_ssm3_p0        ( mode[17] ),
    .op_ssm3_p1        ( mode[18] ),
    .op_ssm4_ks        ( mode[19] ),
    .op_ssm4_ed        ( mode[20] ),

    .ready             ( o_valid  ),
    .rd                ( rd       )
);

initial begin
    clk = 1'b0;
    reset = 1'b0;
    cycle = 0;
end

initial forever #30 clk = ~clk;

always @(posedge clk) begin
    if (cycle >= `MAX_CYCLES) $finish();

    if (cycles == 1) begin
        reset = 1'b1;
        mode = 21'h000008;
        imm = 2'b00;
        rs1 = 32'h00001000;
        rs2 = 32'h00000111;
        i_valid = 1'b1;
    end else begin
        i_valid = 1'b0;
    end

    log(rs1, rs2, rs3);
    cycle = cycle + 1;
end

endmodule
