`define DM_BYTE     1'b001
`define DM_HALF     1'b010
`define DM_WORD     1'b100


module sr_control
(
    input     [ 6:0] cmdOp,
    input     [ 2:0] cmdF3,
    input     [ 6:0] cmdF7,
    input            aluZero,
    output           pcSrc,     // pcBranch : pcPlus4
    output reg       regWrite,  // rf write enable
    output reg       aluSrc,    // immediate : rd2
    output reg       wdSrc,     // immU : execResult
    output reg       immPick,   // immS : immI                  // TODO
    output reg       memToReg,  // dmDataR : aluResult          // TODO
    output reg       dmWe,      // data memory write enable     // TODO
    output reg       dmSign,    // data memory signed read      // TODO
    output reg [3:0] aluControl,
    output           dmOpByte,   // data memory operation mode   // TODO
    output           dmOpHalf,
    output           dmOpWord
);
    reg          branch;
    reg          condZero;
    reg    [2:0] dmOpMode;

    assign {dmOpWord, dmOpHalf, dmOpByte} = dmOpMode;
    assign pcSrc = branch & (aluZero == condZero);

    always @ (*) begin
        branch      = 1'b0;
        condZero    = 1'b0;
        regWrite    = 1'b0;
        aluSrc      = 1'b0;
        wdSrc       = 1'b0;
        immPick     = 1'b0;
        memToReg    = 1'b0;
        dmWe        = 1'b0;
        dmSign      = 1'b0;
        aluControl  = `ALU_ADD;
        dmOpMode    = `DM_WORD;

        casez( { cmdF7, cmdF3, cmdOp } )
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD   } : begin
                regWrite = 1'b1;
                aluControl = `ALU_ADD;
            end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR    } : begin
                regWrite = 1'b1;
                aluControl = `ALU_OR;
            end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL   } : begin
                regWrite = 1'b1;
                aluControl = `ALU_SRL;
            end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU  } : begin
                regWrite = 1'b1;
                aluControl = `ALU_SLTU;
            end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB   } : begin
                regWrite = 1'b1;
                aluControl = `ALU_SUB;
            end
            { `RVF7_XOR,  `RVF3_XOR,  `RVOP_XOR   } : begin
                regWrite = 1'b1;
                aluControl = `ALU_XOR;
            end
            { `RVF7_AND,  `RVF3_AND,  `RVOP_AND   } : begin
                regWrite = 1'b1;
                aluControl = `ALU_AND;
            end
            { `RVF7_SLL,  `RVF3_SLL,  `RVOP_SLL   } : begin
                regWrite = 1'b1;
                aluControl = `ALU_SLL;
            end
            { `RVF7_SRA,  `RVF3_SRA,  `RVOP_SRA   } : begin
                regWrite = 1'b1;
                aluControl = `ALU_SRA;
            end
            { `RVF7_SLT,  `RVF3_SLT,  `RVOP_SLT   } : begin
                regWrite = 1'b1;
                aluControl = `ALU_SLT;
            end


            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI  } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_ADD;
            end
            { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI  } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_XOR;
            end
            { `RVF7_ANY,  `RVF3_ORI,  `RVOP_ORI   } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_OR;
            end
            { `RVF7_ANY,  `RVF3_ANDI, `RVOP_ANDI  } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_AND;
            end
            { `RVF7_ANY,  `RVF3_SLLI, `RVOP_SLLI  } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_SLL;
            end
            { `RVF7_SLLI, `RVF3_SLLI, `RVOP_SLLI  } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_SLL;
            end
            { `RVF7_SRLI, `RVF3_SRLI, `RVOP_SRLI  } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_SRL;
            end
            { `RVF7_SRAI, `RVF3_SRAI, `RVOP_SRAI  } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_SRA;
            end
            { `RVF7_ANY,  `RVF3_SLTI, `RVOP_SLTI  } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_SLT;
            end
            { `RVF7_ANY,  `RVF3_SLTIU,`RVOP_SLTIU } : begin
                regWrite = 1'b1;
                aluSrc = 1'b1;
                aluControl = `ALU_SLTU;
            end


            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI   } : begin
                regWrite = 1'b1;
                wdSrc  = 1'b1;
            end


            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ   } : begin
                branch = 1'b1;
                condZero = 1'b1;
                aluControl = `ALU_SUB;
            end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE   } : begin
                branch = 1'b1;
                aluControl = `ALU_SUB;
            end
        endcase
    end
endmodule
