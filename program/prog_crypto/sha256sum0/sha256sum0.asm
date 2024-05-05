.text
addi a1, zero, 5    # rs1

# ror32(inb, 2)
addi a7, zero, 2
andi t0, a7, 31      # shamt = X(rs2)[4..0]
srl t2, a1, t0      # (X(rs1) >> shamt)
addi a5, zero, 32   # xlen
sub t1, a5, t0      # (xlen - shamt)
sll t1, a1, t1      # (X(rs1) << (xlen - shamt))
or a2, t2, t1

# ror32(inb, 13)
addi a7, zero, 13
andi t0, a7, 31      # shamt = X(rs2)[4..0]
srl t2, a1, t0      # (X(rs1) >> shamt)
sub t1, a5, t0      # (xlen - shamt)
sll t1, a1, t1      # (X(rs1) << (xlen - shamt))
or a3, t2, t1

# ror32(inb, 22)
addi a7, zero, 22
andi t0, a7, 31      # shamt = X(rs2)[4..0]
srl t2, a1, t0      # (X(rs1) >> shamt)
sub t1, a5, t0      # (xlen - shamt)
sll t1, a1, t1      # (X(rs1) << (xlen - shamt))
or a4, t2, t1

xor a0, a2, a3
xor a0, a0, a4

loop:
   j loop
