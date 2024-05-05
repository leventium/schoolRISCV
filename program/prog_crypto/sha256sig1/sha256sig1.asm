.text
addi a1, zero, 5    # rs1

# ror32(inb, 17)
addi a7, zero, 17
andi t0, a7, 31      # shamt = X(rs2)[4..0]
srl t2, a1, t0       # (X(rs1) >> shamt)
addi a5, zero, 32    # xlen
sub t1, a5, t0       # (xlen - shamt)
sll t1, a1, t1       # (X(rs1) << (xlen - shamt))
or a2, t2, t1

# ror32(inb, 19)
addi a7, zero, 19
andi t0, a7, 31      # shamt = X(rs2)[4..0]
srl t2, a1, t0       # (X(rs1) >> shamt)
sub t1, a5, t0       # (xlen - shamt)
sll t1, a1, t1       # (X(rs1) << (xlen - shamt))
or a3, t2, t1

srli a4, a1, 10 
xor a0, a2, a3
xor a0, a0, a4

loop:
   j loop
