/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 */ 

//ALU commands
`define ALU_ADD     4'b0000
`define ALU_OR      4'b0001
`define ALU_SRL     4'b0010
`define ALU_LTU     4'b0011
`define ALU_SUB     4'b0100
`define ALU_XOR     4'b0101
`define ALU_AND     4'b0110
`define ALU_SLL     4'b0111
`define ALU_SRA     4'b1000
`define ALU_LT      4'b1001

// instruction opcode
`define RVOP_ADDI   7'b0010011
`define RVOP_BNCH   7'b1100011
`define RVOP_LUI    7'b0110111
`define RVOP_ADD    7'b0110011
`define RVOP_OR     7'b0110011
`define RVOP_SRL    7'b0110011
`define RVOP_SLTU   7'b0110011
`define RVOP_SUB    7'b0110011
`define RVOP_XOR    7'b0110011
`define RVOP_AND    7'b0110011
`define RVOP_SLL    7'b0110011
`define RVOP_SRA    7'b0110011
`define RVOP_SLT    7'b0110011
`define RVOP_XORI   7'b0010011
`define RVOP_ORI    7'b0010011
`define RVOP_ANDI   7'b0010011
`define RVOP_SLLI   7'b0010011
`define RVOP_SRLI   7'b0010011
`define RVOP_SRAI   7'b0010011
`define RVOP_SLTI   7'b0010011
`define RVOP_SLTIU  7'b0010011
`define RVOP_LOAD   7'b0000011
`define RVOP_STORE  7'b0100011
`define RVOP_JAL    7'b1101111
`define RVOP_JALR   7'b1100111
`define RVOP_AUIPC  7'b0010111

// instruction funct3
`define RVF3_ADDI   3'b000
`define RVF3_BEQ    3'b000
`define RVF3_BNE    3'b001
`define RVF3_BLT    3'b100
`define RVF3_BGE    3'b101
`define RVF3_BLTU   3'b110
`define RVF3_BGEU   3'b111
`define RVF3_ADD    3'b000
`define RVF3_OR     3'b110
`define RVF3_SRL    3'b101
`define RVF3_SLTU   3'b011
`define RVF3_SUB    3'b000
`define RVF3_ANY    3'b???
`define RVF3_XOR    3'b100
`define RVF3_AND    3'b111
`define RVF3_SLL    3'b001
`define RVF3_SRA    3'b101
`define RVF3_SLT    3'b010
`define RVF3_XORI   3'b100
`define RVF3_ORI    3'b110
`define RVF3_ANDI   3'b111
`define RVF3_SLLI   3'b001
`define RVF3_SRLI   3'b101
`define RVF3_SRAI   3'b101
`define RVF3_SLTI   3'b010
`define RVF3_SLTIU  3'b011
`define RVF3_JALR   3'b000

// funct3 Load/Store
`define RVF3_LB     3'b000
`define RVF3_LH     3'b001
`define RVF3_LW     3'b010
`define RVF3_LBU    3'b100
`define RVF3_LHU    3'b101
`define RVF3_SB     3'b000
`define RVF3_SH     3'b001
`define RVF3_SW     3'b010

// instruction funct7
`define RVF7_ADD    7'b0000000
`define RVF7_OR     7'b0000000
`define RVF7_SRL    7'b0000000
`define RVF7_SLTU   7'b0000000
`define RVF7_SUB    7'b0100000
`define RVF7_ANY    7'b???????
`define RVF7_XOR    7'b0000000
`define RVF7_AND    7'b0000000
`define RVF7_SLL    7'b0000000
`define RVF7_SRA    7'b0100000
`define RVF7_SLT    7'b0000000
`define RVF7_SLLI   7'b0000000
`define RVF7_SRLI   7'b0000000
`define RVF7_SRAI   7'b0100000


// WD src
`define WD_SRC_ALU      2'b00
`define WD_SRC_MEM      2'b01
`define WD_SRC_IMMU     2'b10
`define WD_SRC_PC4      2'b11


// PC src1
`define PC_SRC1_4       2'b00
`define PC_SRC1_IMMB    2'b01
`define PC_SRC1_IMMJ    2'b10
`define PC_SRC1_IMMI    2'b11
// PC src2
`define PC_SRC2_PC      1'b0
`define PC_SRC2_RD1     1'b1


// ALU src1 Pick
`define ALU_SRC1_RD1    1'b0
`define ALU_SRC1_PC     1'b1
// ALU src2 Pick
`define ALU_SRC2_RD2    2'b00
`define ALU_SRC2_IMMI   2'b01
`define ALU_SRC2_IMMS   2'b10
`define ALU_SRC2_IMMU   2'b11
