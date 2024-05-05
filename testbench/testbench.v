/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 */ 

`timescale 1 ns / 100 ps

`include "sr_cpu.vh"

`ifndef SIMULATION_CYCLES
    `define SIMULATION_CYCLES 120
`endif

module sm_testbench;

    // simulation options
    parameter Tt     = 20;

    reg         clk;
    reg         rst_n;
    reg  [ 4:0] regAddr;
    wire        cpuClk;

    // ***** DUT start ************************

    sm_top sm_top
    (
        .clkIn     ( clk     ),
        .rst_n     ( rst_n   ),
        .clkDivide ( 4'b0    ),
        .clkEnable ( 1'b1    ),
        .clk       ( cpuClk  ),
        .regAddr   ( 5'b0    ),
        .regData   (         )
    );

    defparam sm_top.sm_clk_divider.bypass = 1;

    // ***** DUT  end  ************************

`ifdef ICARUS
    //iverilog memory dump init workaround
    initial $dumpvars;
    genvar k;
    for (k = 0; k < 32; k = k + 1) begin
        initial $dumpvars(0, sm_top.sm_cpu.rf.rf[k]);
    end
`endif

    // simulation init
    initial begin
        clk = 0;
        forever clk = #(Tt/2) ~clk;
    end

    initial begin
        rst_n   = 0;
        repeat (4)  @(posedge clk);
        rst_n   = 1;
    end

    task disasmInstr;

        reg [ 6:0] cmdOp;
        reg [ 4:0] rd;
        reg [ 2:0] cmdF3;
        reg [ 4:0] rs1;
        reg [ 4:0] rs2;
        reg [ 6:0] cmdF7;
        reg [31:0] immI;
        reg signed [31:0] immB;
        reg [31:0] immU;
        reg [31:0] immS;
        reg [31:0] immJ;

    begin
        cmdOp = sm_top.sm_cpu.cmdOp;
        rd    = sm_top.sm_cpu.rd;
        cmdF3 = sm_top.sm_cpu.cmdF3;
        rs1   = sm_top.sm_cpu.rs1;
        rs2   = sm_top.sm_cpu.rs2;
        cmdF7 = sm_top.sm_cpu.cmdF7;
        immI  = sm_top.sm_cpu.immI;
        immB  = sm_top.sm_cpu.immB;
        immU  = sm_top.sm_cpu.immU;
        immS  = sm_top.sm_cpu.immS;
        immJ  = sm_top.sm_cpu.immJ;

        $write("   ");
        casez( { cmdF7, cmdF3, cmdOp } )
            default :                                $write ("new/unknown");
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : $write ("add   $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : $write ("sub   $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_XOR,  `RVF3_XOR,  `RVOP_XOR  } : $write ("xor   $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : $write ("or    $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_AND,  `RVF3_AND,  `RVOP_AND  } : $write ("and   $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_SLL,  `RVF3_SLL,  `RVOP_SLL  } : $write ("sll   $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : $write ("srl   $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_SRA,  `RVF3_SRA,  `RVOP_SRA  } : $write ("sra   $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_SLT,  `RVF3_SLT,  `RVOP_SLT  } : $write ("slt   $%1d, $%1d, $%1d", rd, rs1, rs2);
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : $write ("sltu  $%1d, $%1d, $%1d", rd, rs1, rs2);

            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : $write ("addi  $%1d, $%1d, %1d", rd, rs1, immI);
            { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI } : $write ("xori  $%1d, $%1d, %1d", rd, rs1, immI);
            { `RVF7_ANY,  `RVF3_ORI,  `RVOP_ORI  } : $write ("ori   $%1d, $%1d, %1d", rd, rs1, immI);
            { `RVF7_ANY,  `RVF3_ANDI, `RVOP_ANDI } : $write ("andi  $%1d, $%1d, %1d", rd, rs1, immI);
            { `RVF7_SLLI, `RVF3_SLLI, `RVOP_SLLI } : $write ("slli  $%1d, $%1d, %1d", rd, rs1, rs2);
            { `RVF7_SRLI, `RVF3_SRLI, `RVOP_SRLI } : $write ("srli  $%1d, $%1d, %1d", rd, rs1, rs2);
            { `RVF7_SRAI, `RVF3_SRAI, `RVOP_SRAI } : $write ("srai  $%1d, $%1d, %1d", rd, rs1, rs2);
            { `RVF7_ANY,  `RVF3_SLTI, `RVOP_SLTI } : $write ("slti  $%1d, $%1d, %1d", rd, rs1, immI);
            { `RVF7_ANY,  `RVF3_SLTIU,`RVOP_SLTIU} : $write ("sltiu $%1d, $%1d, %1d", rd, rs1, immI);

            { `RVF7_ANY,  `RVF3_LB,   `RVOP_LOAD } : $write ("lb    $%1d, %d($%1d)",  rd, immI, rs1);
            { `RVF7_ANY,  `RVF3_LH,   `RVOP_LOAD } : $write ("lh    $%1d, %d($%1d)",  rd, immI, rs1);
            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LOAD } : $write ("lw    $%1d, %d($%1d)",  rd, immI, rs1);
            { `RVF7_ANY,  `RVF3_LBU,  `RVOP_LOAD } : $write ("lbu   $%1d, %d($%1d)",  rd, immI, rs1);
            { `RVF7_ANY,  `RVF3_LHU,  `RVOP_LOAD } : $write ("lhu   $%1d, %d($%1d)",  rd, immI, rs1);
            { `RVF7_ANY,  `RVF3_SB,   `RVOP_STORE} : $write ("sb    $%1d, %d($%1d)",  rd, immS, rs1);
            { `RVF7_ANY,  `RVF3_SH,   `RVOP_STORE} : $write ("sh    $%1d, %d($%1d)",  rd, immS, rs1);
            { `RVF7_ANY,  `RVF3_SW,   `RVOP_STORE} : $write ("sw    $%1d, %d($%1d)",  rd, immS, rs1);

            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BNCH } : $write ("beq   $%1d, $%1d, %1d", rs1, rs2, immB);
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNCH } : $write ("bne   $%1d, $%1d, %1d", rs1, rs2, immB);
            { `RVF7_ANY,  `RVF3_BLT,  `RVOP_BNCH } : $write ("blt   $%1d, $%1d, %1d", rs1, rs2, immB);
            { `RVF7_ANY,  `RVF3_BGE,  `RVOP_BNCH } : $write ("bge   $%1d, $%1d, %1d", rs1, rs2, immB);
            { `RVF7_ANY,  `RVF3_BLTU, `RVOP_BNCH } : $write ("bltu  $%1d, $%1d, %1d", rs1, rs2, immB);
            { `RVF7_ANY,  `RVF3_BGEU, `RVOP_BNCH } : $write ("bgeu  $%1d, $%1d, %1d", rs1, rs2, immB);

            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL  } : $write ("jal   $%1d, %1d",       rd, immJ);
            { `RVF7_ANY,  `RVF3_JALR, `RVOP_JALR } : $write ("jalr  $%1d, $%1d, %1d", rd, rs1, immI);

            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : $write ("lui   $%1d, 0x%8h",     rd, immU);
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_AUIPC} : $write ("auipc $%1d, 0x%8h",     rd, immU);
        endcase
    end
    endtask


    //simulation debug output
    integer cycle; initial cycle = 0;

    always @ (posedge clk)
    begin
        $write ("%5d  pc = %2h instr = %h   a0 = 0x%8h",
                  cycle, sm_top.sm_cpu.pc, sm_top.sm_cpu.instr, sm_top.sm_cpu.rf.rf[10]);

        disasmInstr();

        $write("\n");

        cycle = cycle + 1;

        if (cycle > `SIMULATION_CYCLES)
        begin
            cycle = 0;
            $display ("Timeout");
            $stop;
        end
    end

endmodule
