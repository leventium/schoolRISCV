/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 */ 

`include "sr_cpu.vh"

module sr_cpu
(
    input           clk,        // clock
    input           rst_n,      // reset
    input   [ 4:0]  regAddr,    // debug access reg address
    output  [31:0]  regData,    // debug access reg data
    output  [31:0]  imAddr,     // instruction memory address
    input   [31:0]  imData,     // instruction memory data

    // Data Memory
    output  [31:0]  dmAddr,
    output  [31:0]  dmDataW,
    output          dmWe,
    output          op_byte,
    output          op_half,
    output          op_word,
    output          dmSign,
    input   [31:0]  dmDataR
);
    //control wires
    wire        aluZero;
    wire        regWrite;
    wire        aluSrc;
    wire [ 1:0] pcSrc1;
    wire        pcSrc2;
    wire        aluSrc1;
    wire [ 1:0] aluSrc2;
    wire [ 2:0] wdSrc;
    wire [ 3:0] aluControl;

    //instruction decode wires
    wire [ 6:0] cmdOp;
    wire [ 4:0] rd;
    wire [ 2:0] cmdF3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] cmdF7;
    wire [31:0] immI;
    wire [31:0] immB;
    wire [31:0] immU;
    wire [31:0] immS;
    wire [31:0] immJ;

    // crypto module
    wire [31:0] cryResult;

    // Program Counter
    wire [31:0] pc;
    wire [31:0] pcPlus4     = pc + 4;

    reg  [31:0] pcSrc1In;
    wire [31:0] pcSrc2In    = pcSrc2 ? rd1 : pc;
    wire [31:0] pcNext      = pcSrc1In + pcSrc2In;
    wire        pc_hold;
    wire        pc_we = ~pc_hold;

    always @(*) begin
        case ( pcSrc1 )
            `PC_SRC1_4      : pcSrc1In  = 32'h00000004;
            `PC_SRC1_IMMB   : pcSrc1In  = immB;
            `PC_SRC1_IMMJ   : pcSrc1In  = immJ;
            `PC_SRC1_IMMI   : pcSrc1In  = immI;
            default         : pcSrc1In  = 32'h00000004;
        endcase
    end

    sm_register_we r_pc(clk, rst_n, pc_we, pcNext, pc);


    //program memory access
    assign imAddr = pc >> 2;
    wire [31:0] instr = imData;


    // Instruction Decode
    sr_decode id (
        .instr      ( instr        ),
        .cmdOp      ( cmdOp        ),
        .rd         ( rd           ),
        .cmdF3      ( cmdF3        ),
        .rs1        ( rs1          ),
        .rs2        ( rs2          ),
        .cmdF7      ( cmdF7        ),
        .immI       ( immI         ),
        .immB       ( immB         ),
        .immU       ( immU         ),
        .immS       ( immS         ),
        .immJ       ( immJ         )
    );


    //register file
    wire [31:0] rd0;
    wire [31:0] rd1;
    wire [31:0] rd2;
    reg  [31:0] wd3;

    always @(*) begin
        case (wdSrc)
            `WD_SRC_ALU   : wd3 = aluResult;
            `WD_SRC_MEM   : wd3 = dmDataR;
            `WD_SRC_IMMU  : wd3 = immU;
            `WD_SRC_PC4   : wd3 = pcPlus4;
            `WD_SRC_CRYPT : wd3 = cryResult;
            default       : wd3 = aluResult;
        endcase
    end

    sm_register_file rf (
        .clk        ( clk          ),
        .a0         ( regAddr      ),
        .a1         ( rs1          ),
        .a2         ( rs2          ),
        .a3         ( rd           ),
        .rd0        ( rd0          ),
        .rd1        ( rd1          ),
        .rd2        ( rd2          ),
        .wd3        ( wd3          ),
        .we3        ( regWrite     )
    );


    //debug register access
    assign regData = (regAddr != 0) ? rd0 : pc;


    // ALU
    wire [31:0] aluSrc1In = aluSrc1 ? pc : rd1;
    reg  [31:0] aluSrc2In;
    wire [31:0] aluResult;

    always @ (*) begin
        case (aluSrc2)
            `ALU_SRC2_RD2   : aluSrc2In = rd2;
            `ALU_SRC2_IMMI  : aluSrc2In = immI;
            `ALU_SRC2_IMMS  : aluSrc2In = immS;
            `ALU_SRC2_IMMU  : aluSrc2In = immU;
            default         : aluSrc2In = rd2;
        endcase
    end

    sr_alu alu (
        .srcA       ( aluSrc1In    ),
        .srcB       ( aluSrc2In    ),
        .oper       ( aluControl   ),
        .zero       ( aluZero      ),
        .result     ( aluResult    ) 
    );


    // crypto
    wire [20:0] cryptMode;

    riscv_crypto_fu_rv32 crypto_module (
        .g_clk             ( clk           ),
        .g_resetn          ( rst_n         ),

        .valid             ( 1'b1          ),
        .rs1               ( rd1           ),
        .rs2               ( rd2           ),
        .imm               ( instr[31:30]  ), // TODO: modify decoder

        .op_lut4lo         ( cryptMode[ 0] ), // TODO: remove unused modes
        .op_lut4hi         ( cryptMode[ 1] ),
        .op_lut4           ( cryptMode[ 2] ),
        .op_saes32_encs    ( cryptMode[ 3] ),
        .op_saes32_encsm   ( cryptMode[ 4] ),
        .op_saes32_decs    ( cryptMode[ 5] ),
        .op_saes32_decsm   ( cryptMode[ 6] ),
        .op_ssha256_sig0   ( cryptMode[ 7] ),
        .op_ssha256_sig1   ( cryptMode[ 8] ),
        .op_ssha256_sum0   ( cryptMode[ 9] ),
        .op_ssha256_sum1   ( cryptMode[10] ),
        .op_ssha512_sum0r  ( cryptMode[11] ),
        .op_ssha512_sum1r  ( cryptMode[12] ),
        .op_ssha512_sig0l  ( cryptMode[13] ),
        .op_ssha512_sig0h  ( cryptMode[14] ),
        .op_ssha512_sig1l  ( cryptMode[15] ),
        .op_ssha512_sig1h  ( cryptMode[16] ),
        .op_ssm3_p0        ( cryptMode[17] ),
        .op_ssm3_p1        ( cryptMode[18] ),
        .op_ssm4_ks        ( cryptMode[19] ),
        .op_ssm4_ed        ( cryptMode[20] ),

        .rd                ( cryResult     )
    );


    // control unit
    sr_control sr_control (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),

        .cmdOp      ( cmdOp      ),
        .cmdF3      ( cmdF3      ),
        .cmdF7      ( cmdF7      ),
        .cmdF5_rs2  ( rs2        ),
        .aluZero    ( aluZero    ),

        .regWrite   ( regWrite   ),
        .hold       ( pc_hold    ),

        .aluControl ( aluControl ),
        .aluSrc1    ( aluSrc1    ),
        .aluSrc2    ( aluSrc2    ),
        .pcSrc1     ( pcSrc1     ),
        .pcSrc2     ( pcSrc2     ),
        .wdSrc      ( wdSrc      ),

        .dmWe       ( dmWe       ),
        .dmSign     ( dmSign     ),
        .dmOpByte   ( op_byte    ),
        .dmOpHalf   ( op_half    ),
        .dmOpWord   ( op_word    ),

        .cryptMode ( cryptMode   )
    );


    // Memory
    assign dmAddr = aluResult;
    assign dmDataW = rd2;

endmodule

module sr_alu
(
    input      [31:0] srcA,
    input      [31:0] srcB,
    input      [ 3:0] oper,
    output            zero,
    output reg [31:0] result
);
    always @ (*) begin
        case (oper)
            default   : result = srcA + srcB;
            `ALU_ADD  : result = srcA + srcB;
            `ALU_OR   : result = srcA | srcB;
            `ALU_SRL  : result = srcA >> srcB[4:0];
            `ALU_LTU  : result = (srcA < srcB) ? 1 : 0;
            `ALU_SUB  : result = srcA - srcB;
            `ALU_XOR  : result = srcA ^ srcB;
            `ALU_AND  : result = srcA & srcB;
            `ALU_SLL  : result = srcA << srcB[4:0];
            `ALU_SRA  : result = srcA >>> srcB[4:0];
            `ALU_LT   : result = ($signed(srcA) < $signed(srcB)) ? 1 : 0;
        endcase
    end

    assign zero   = (result == 0);
endmodule

module sm_register_file
(
    input         clk,
    input  [ 4:0] a0,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    output [31:0] rd0,
    output [31:0] rd1,
    output [31:0] rd2,
    input  [31:0] wd3,
    input         we3
);
    reg [31:0] rf [31:0];

    assign rd0 = (a0 != 0) ? rf [a0] : 32'b0;
    assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;

    always @ (posedge clk)
        if(we3) rf [a3] <= wd3;
endmodule
