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
