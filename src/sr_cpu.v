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
    output          w_byte,
    output          w_half,
    output          w_word,
    output          sign,
    input   [31:0]  dmDataR,
);
    //control wires
    wire        aluZero;
    wire        pcSrc;
    wire        regWrite;
    wire        aluSrc;
    wire        wdSrc;
    wire        immPick;
    wire        memToReg;
    wire  [3:0] aluControl;
    wire  [3:0] dmRMode;

    assign { w_byte, w_half, w_word } = dmRMode;

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

    //program counter
    wire [31:0] pc;
    wire [31:0] pcBranch = pc + immB;
    wire [31:0] pcPlus4  = pc + 4;
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;
    sm_register r_pc(clk ,rst_n, pcNext, pc);

    //program memory access
    assign imAddr = pc >> 2;
    wire [31:0] instr = imData;

    //instruction decode
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
    wire [31:0] immediate = immPick ? immI : immS;
    wire [31:0] srcB = aluSrc ? immediate : rd2;
    wire [31:0] execResult;
    wire [31:0] aluResult;

    sr_alu alu (
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .zero       ( aluZero      ),
        .result     ( aluResult    ) 
    );

    assign execResult = memToReg ? dmDataR : aluResult;
    assign wd3 = wdSrc ? immU : execResult;

    //control
    sr_control sm_control (
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
        .dmRMode    ( dmRMode    )
    );

    // memory
    assign dmAddr = aluResult;
    assign dmDataW = rd2;

endmodule

module sr_decode
(
    input      [31:0] instr,
    output     [ 6:0] cmdOp,
    output     [ 4:0] rd,
    output     [ 2:0] cmdF3,
    output     [ 4:0] rs1,
    output     [ 4:0] rs2,
    output     [ 6:0] cmdF7,
    output reg [31:0] immI,
    output reg [31:0] immB,
    output reg [31:0] immU,
    output reg [31:0] immS,
    output reg [31:0] immJ
);
    assign cmdOp = instr[ 6: 0];
    assign rd    = instr[11: 7];
    assign cmdF3 = instr[14:12];
    assign rs1   = instr[19:15];
    assign rs2   = instr[24:20];
    assign cmdF7 = instr[31:25];

    // I-immediate
    always @ (*) begin
        immI[10: 0] = instr[30:20];
        immI[31:11] = { 21 {instr[31]} };
    end

    // B-immediate
    always @ (*) begin
        immB[    0] = 1'b0;
        immB[ 4: 1] = instr[11:8];
        immB[10: 5] = instr[30:25];
        immB[   11] = instr[7];
        immB[31:12] = { 20 {instr[31]} };
    end

    // U-immediate
    always @ (*) begin
        immU[11: 0] = 12'b0;
        immU[31:12] = instr[31:12];
    end

    // S-immediate
    always @(*) begin
        immS[ 4: 0] = instr[11: 7];
        immS[10: 5] = instr[30:25];
        immS[31:11] = { 21 { instr[31] } };
    end

    // J-immediate
    always @ (*) begin
        immJ[    0] = 1'b0;
        immJ[10: 1] = instr[30:21];
        immJ[   11] = instr[20];
        immJ[19:12] = instr[19:12];
        immJ[31:20] = { 12 {instr[31]} };
    end

endmodule

module sr_control
(
    input     [ 6:0] cmdOp,
    input     [ 2:0] cmdF3,
    input     [ 6:0] cmdF7,
    input            aluZero,
    output           pcSrc, 
    output reg       regWrite, 
    output reg       aluSrc,
    output reg       wdSrc,
    output reg       immPick,    // TODO
    output reg       memToReg,   // TODO
    output reg       dmWe,       // TODO
    output reg [3:0] aluControl,
    output reg [2:0] dmRMode     // TODO
);
    reg          branch;
    reg          condZero;
    assign pcSrc = branch & (aluZero == condZero);

    always @ (*) begin
        branch      = 1'b0;
        condZero    = 1'b0;
        regWrite    = 1'b0;
        aluSrc      = 1'b0;
        wdSrc       = 1'b0;
        aluControl  = `ALU_ADD;

        casez( {cmdF7, cmdF3, cmdOp } )
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD   } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR    } : begin regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL   } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU  } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB   } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  end
            { `RVF7_XOR,  `RVF3_XOR,  `RVOP_XOR   } : begin regWrite = 1'b1; aluControl = `ALU_XOR;  end
            { `RVF7_AND,  `RVF3_AND,  `RVOP_AND   } : begin regWrite = 1'b1; aluControl = `ALU_AND;  end
            { `RVF7_SLL,  `RVF3_SLL,  `RVOP_SLL   } : begin regWrite = 1'b1; aluControl = `ALU_SLL;  end
            { `RVF7_SRA,  `RVF3_SRA,  `RVOP_SRA   } : begin regWrite = 1'b1; aluControl = `ALU_SRA;  end
            { `RVF7_SLT,  `RVF3_SLT,  `RVOP_SLT   } : begin regWrite = 1'b1; aluControl = `ALU_SLT;  end

            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; end
            { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_XOR; end
            { `RVF7_ANY,  `RVF3_ORI,  `RVOP_ORI   } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_OR;  end
            { `RVF7_ANY,  `RVF3_ANDI, `RVOP_ANDI  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_AND; end
            { `RVF7_ANY,  `RVF3_SLLI, `RVOP_SLLI  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_SLL; end
            { `RVF7_SLLI, `RVF3_SLLI, `RVOP_SLLI  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_SLL; end
            { `RVF7_SRLI, `RVF3_SRLI, `RVOP_SRLI  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_SRL; end
            { `RVF7_SRAI, `RVF3_SRAI, `RVOP_SRAI  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_SRA; end
            { `RVF7_ANY,  `RVF3_SLTI, `RVOP_SLTI  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_SLT; end
            { `RVF7_ANY,  `RVF3_SLTIU,`RVOP_SLTIU } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_SLTU;end
                
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI   } : begin regWrite = 1'b1; wdSrc  = 1'b1; end

            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ   } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUB; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE   } : begin branch = 1'b1; aluControl = `ALU_SUB; end
        endcase
    end
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
            `ALU_SLTU : result = (srcA < srcB) ? 1 : 0;
            `ALU_SUB  : result = srcA - srcB;
            `ALU_XOR  : result = srcA ^ srcB;
            `ALU_AND  : result = srcA & srcB;
            `ALU_SLL  : result = srcA << srcB[4:0];
            `ALU_SRA  : result = srcA >>> srcB[4:0];
            `ALU_SLT  : result = ($signed(srcA) < $signed(srcB)) ? 1 : 0;
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
