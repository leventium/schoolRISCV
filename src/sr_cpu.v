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
    input   [31:0]  dmDataR,
);
    //control wires
    wire        aluZero;
    // wire        pcSrc;
    wire        regWrite;
    wire        aluSrc;
    // wire        wdSrc;
    // wire        immPick;
    // wire        memToReg;
    wire        src1Pick;
    wire  [1:0] src2Pick;
    wire  [1:0] wd3Pick;
    wire  [1:0] pcOp1;
    wire        pcOp2;
    wire  [3:0] aluControl;

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

    // Program Counter
    wire [31:0] pc;
    wire [31:0] pcBranch = pc + immB;
    wire [31:0] pcPlus4  = pc + 4;
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;


    reg         pcSrc1;
    wire        pcSrc2   = // TODO
    wire [31:0] pcNext   = // TODO


    sm_register r_pc(clk, rst_n, pcNext, pc);


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
    wire [31:0] wd3;

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

    //alu
    // wire [31:0] immediate = immPick ? immS : immI;  // TODO src2 Pick
    // wire [31:0] srcB = aluSrc ? immediate : rd2;
    // wire [31:0] execResult;
    wire [31:0] aluResult;

    sr_alu alu (
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .zero       ( aluZero      ),
        .result     ( aluResult    ) 
    );

    // assign execResult = memToReg ? dmDataR : aluResult; // TODO wd Pick
    // assign wd3 = wdSrc ? immU : execResult;

    //control
    sr_control sr_control (
        .cmdOp      ( cmdOp      ),
        .cmdF3      ( cmdF3      ),
        .cmdF7      ( cmdF7      ),
        .aluZero    ( aluZero    ),
        .pcSrc      ( pcSrc      ),
        .regWrite   ( regWrite   ),
        .aluSrc     ( aluSrc     ),
        .wdSrc      ( wdSrc      ),
        .aluControl ( aluControl ),
        .immPick    ( immPick    ),
        .memToReg   ( memToReg   ),
        .dmWe       ( dmWe       ),
        .dmSign     ( dmSign     ),
        .dmOpByte   ( op_byte    ),
        .dmOpHalf   ( op_half    ),
        .dmOpWord   ( op_word    ),
    );

    // memory
    assign dmAddr = aluResult;
    assign dmDataW = rd2;

endmodule

module sr_alu
(
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [ 3:0] oper,
    output        zero,
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
