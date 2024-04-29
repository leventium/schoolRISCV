`include "sr_cpu.vh"

`define DM_BYTE     3'b001
`define DM_HALF     3'b010
`define DM_WORD     3'b100

`define SELECT_COMB 1'b0;
`define SELECT_CRYP 1'b1;


module sr_control
(
    input      [ 6:0] cmdOp,
    input      [ 2:0] cmdF3,
    input      [ 6:0] cmdF7,
    input      [ 4:0] cmdF5_rs2,
    input             aluZero,

    output reg        hold,
    // output           pcSrc,     // pcBranch : pcPlus4
    output reg        regWrite,  // rf write enable
    // output reg       aluSrc,    // immediate : rd2
    // output reg       wdSrc,     // immU : execResult
    // output reg       immPick,   // immS : immI
    // output reg       memToReg,  // dmDataR : aluResult

    // multiplexers
    output reg        aluSrc1,
    output reg  [1:0] aluSrc2,
    output reg  [3:0] aluControl,
    output reg  [1:0] pcSrc1,
    output reg        pcSrc2,
    output reg  [2:0] wdSrc,

    // memory
    output reg        dmWe,      // data memory write enable
    output reg        dmSign,    // data memory signed read
    output            dmOpByte,   // data memory operation mode
    output            dmOpHalf,
    output            dmOpWord,

    // crypto module
    // output reg        cry_i_valid,
    output reg [20:0] cryptoMode
);
    wire         branch;
    reg          condZero;
    reg    [2:0] dmOpMode;

    assign {dmOpWord, dmOpHalf, dmOpByte} = dmOpMode;
    assign branch = (aluZero == condZero);

    always @ (*) begin
        condZero    = 1'b0;
        regWrite    = 1'b0;
        // aluSrc      = 1'b0;
        // wdSrc       = 1'b0;
        // immPick     = 1'b0;
        // memToReg    = 1'b0;

        wdSrc       = `WD_SRC_ALU;
        pcSrc1      = `PC_SRC1_4;
        pcSrc2      = `PC_SRC2_PC;
        aluSrc1     = `ALU_SRC1_RD1;
        aluSrc2     = `ALU_SRC2_RD2;
        aluControl  = `ALU_ADD;

        dmWe        = 1'b0;
        dmSign      = 1'b0;
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
                aluControl = `ALU_LTU;
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
                aluControl = `ALU_LT;
            end


            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_ADD;
            end
            { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_XOR;
            end
            { `RVF7_ANY,  `RVF3_ORI,  `RVOP_ORI   } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_OR;
            end
            { `RVF7_ANY,  `RVF3_ANDI, `RVOP_ANDI  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_AND;
            end
            // TODO: check necessity of this block
            // { `RVF7_ANY,  `RVF3_SLLI, `RVOP_SLLI  } : begin
            //     regWrite = 1'b1;
            //     aluSrc2 = `ALU_SRC2_IMMI;
            //     aluControl = `ALU_SLL;
            // end
            { `RVF7_SLLI, `RVF3_SLLI, `RVOP_SLLI  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_SLL;
            end
            { `RVF7_SRLI, `RVF3_SRLI, `RVOP_SRLI  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_SRL;
            end
            { `RVF7_SRAI, `RVF3_SRAI, `RVOP_SRAI  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_SRA;
            end
            { `RVF7_ANY,  `RVF3_SLTI, `RVOP_SLTI  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_LT;
            end
            { `RVF7_ANY,  `RVF3_SLTIU,`RVOP_SLTIU } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                aluControl = `ALU_LTU;
            end


            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BNCH  } : begin
                pcSrc1 = { 1'b0, branch };
                condZero = 1'b1;
                aluControl = `ALU_SUB;
            end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNCH  } : begin
                pcSrc1 = { 1'b0, branch };
                aluControl = `ALU_SUB;
            end
            { `RVF7_ANY,  `RVF3_BLT,  `RVOP_BNCH  } : begin
                pcSrc1 = { 1'b0, branch };
                aluControl = `ALU_LT;
            end
            { `RVF7_ANY,  `RVF3_BGE,  `RVOP_BNCH  } : begin
                pcSrc1 = { 1'b0, branch };
                condZero = 1'b1;
                aluControl = `ALU_LT;
            end
            { `RVF7_ANY,  `RVF3_BLTU, `RVOP_BNCH  } : begin
                pcSrc1 = { 1'b0, branch };
                aluControl = `ALU_LTU;
            end
            { `RVF7_ANY,  `RVF3_BGEU, `RVOP_BNCH  } : begin
                pcSrc1 = { 1'b0, branch };
                condZero = 1'b1;
                aluControl = `ALU_LTU;
            end


            // load instructions
            { `RVF7_ANY,  `RVF3_LB,   `RVOP_LOAD  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                wdSrc = `WD_SRC_MEM;

                dmOpMode = `DM_BYTE;
                dmSign = 1'b1;
            end
            { `RVF7_ANY,  `RVF3_LH,   `RVOP_LOAD  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                wdSrc = `WD_SRC_MEM;

                dmOpMode = `DM_HALF;
                dmSign = 1'b1;
            end
            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LOAD  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                wdSrc = `WD_SRC_MEM;

                dmOpMode = `DM_WORD;
                dmSign = 1'b1;
            end
            { `RVF7_ANY,  `RVF3_LBU,  `RVOP_LOAD  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                wdSrc = `WD_SRC_MEM;

                dmOpMode = `DM_BYTE;
            end
            { `RVF7_ANY,  `RVF3_LHU,  `RVOP_LOAD  } : begin
                regWrite = 1'b1;
                aluSrc2 = `ALU_SRC2_IMMI;
                wdSrc = `WD_SRC_MEM;

                dmOpMode = `DM_HALF;
            end


            // store instructions
            { `RVF7_ANY,  `RVF3_SB,   `RVOP_STORE } : begin
                aluSrc2     = `ALU_SRC2_IMMS;
                dmWe        = 1'b1;

                dmOpMode    = `DM_BYTE;
            end
            { `RVF7_ANY,  `RVF3_SH,   `RVOP_STORE } : begin
                aluSrc2     = `ALU_SRC2_IMMS;
                dmWe        = 1'b1;

                dmOpMode    = `DM_HALF;
            end
            { `RVF7_ANY,  `RVF3_SW,   `RVOP_STORE } : begin
                aluSrc2     = `ALU_SRC2_IMMS;
                dmWe        = 1'b1;

                dmOpMode    = `DM_WORD;
            end


            // jump instructions
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL  } : begin
                wdSrc       = `WD_SRC_PC4;
                regWrite    = 1'b1;
                pcSrc1      = `PC_SRC1_IMMJ;
            end
            { `RVF7_ANY,  `RVF3_JALR, `RVOP_JALR } : begin
                wdSrc       = `WD_SRC_PC4;
                regWrite    = 1'b1;
                pcSrc1      = `PC_SRC1_IMMI;
                pcSrc2      = `PC_SRC2_RD1;
            end


            // lui
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI   } : begin
                regWrite = 1'b1;
                wdSrc = `WD_SRC_IMMU;
            end
            // auipc
            { `RVF7_ANY,  `RVF3_ANY, `RVOP_AUIPC } : begin
                aluSrc1     = `ALU_SRC1_PC;
                aluSrc2     = `ALU_SRC2_IMMU;
                regWrite    = 1'b1;
                aluControl  = `ALU_ADD;
            end


            default: aluControl = `ALU_ADD;
        endcase
    end
endmodule


// TODO: сделай необходимые define'ы для каждого режима,
// так будет проще понимать
// example
`define CRYPT_MODE_VOID 21'h000000

module crypto_detector (
    input      [ 6:0]  opcode,
    input      [ 2:0]  func3,
    input      [ 6:0]  func7,
    input      [ 4:0]  func5_rs2,

    output reg         res,
    output reg [20:0]  cryptMode
);

    always @* begin
        res = 1'b1;

        casez ({ func5_rs2, func7, func3, opcode })
            { `RVF5_ANY,         `RVF7_AES32DSI,     `RVF3_AES,     `RVOP_AES    }: cryptMode = `CRYPT_MODE_VOID; // example
            { `RVF5_ANY,         `RVF7_AES32DSMI,    `RVF3_AES,     `RVOP_AES    }: // TODO: и так далее
            { `RVF5_ANY,         `RVF7_AES32ESI,     `RVF3_AES,     `RVOP_AES    }:
            { `RVF5_ANY,         `RVF7_AES32ESMI,    `RVF3_AES,     `RVOP_AES    }:
            { `RVF5_SHA256SIG0,  `RVF7_SHA256,       `RVF3_SHA256,  `RVOP_SHA256 }:
            { `RVF5_SHA256SIG1,  `RVF7_SHA256,       `RVF3_SHA256,  `RVOP_SHA256 }:
            { `RVF5_SHA256SUM0,  `RVF7_SHA256,       `RVF3_SHA256,  `RVOP_SHA256 }:
            { `RVF5_SHA256SUM1,  `RVF7_SHA256,       `RVF3_SHA256,  `RVOP_SHA256 }:
            { `RVF5_ANY,         `RVF7_SHA512SIG0H,  `RVF3_SHA512,  `RVOP_SHA512 }:
            { `RVF5_ANY,         `RVF7_SHA512SIG0L,  `RVF3_SHA512,  `RVOP_SHA512 }:
            { `RVF5_ANY,         `RVF7_SHA512SIG1H,  `RVF3_SHA512,  `RVOP_SHA512 }:
            { `RVF5_ANY,         `RVF7_SHA512SIG1L,  `RVF3_SHA512,  `RVOP_SHA512 }:
            { `RVF5_ANY,         `RVF7_SHA512SUM0R,  `RVF3_SHA512,  `RVOP_SHA512 }:
            { `RVF5_ANY,         `RVF7_SHA512SUM1R,  `RVF3_SHA512,  `RVOP_SHA512 }:

            default: begin
                res = 1'b0;
                cryptMode = 21'b000000;
            end
        endcase
    end

endmodule


module crypto_fsm (
    input       clk,
    input       rst_n,
    input       crypt_instr,

    output reg  ctrls_select,
    output reg  hold,
    output reg  regWrite
);

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            state <= S0;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            S0: next_state = crypt_instr ? S1 : S0;
            S1: next_state = S2;
            S2: next_state = S0;

            default: next_state = S0;
        endcase
    end

    always @(*) begin
        case (next_state)
            S1: begin
                hold = 1'b1;
                ctrls_select = `SELECT_CRYP;
                regWrite = 1'b0;
            end
            S2: begin
                hold = 1'b0;
                ctrls_select = `SELECT_CRYP;
                regWrite = 1'b1;
            end

            default: begin
                hold = 1'b0;
                ctrls_select = `SELECT_COMB;
                regWrite = 1'b0;
            end
        endcase
    end

endmodule
