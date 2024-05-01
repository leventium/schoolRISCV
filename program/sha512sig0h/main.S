.text
addi a1, zero, 5    # rs1
addi a2, zero, 8    # rs2

srli a3, a1, 1      # (X(rs1) >> 1)
srli a4, a1, 7      # (X(rs1) >> 7)
srli a5, a1, 8      # (X(rs1) >> 8)

slli a6, a2, 31     # (X(rs2) << 31)
slli a7, a2, 24     # (X(rs2) << 24)

xor a3, a3, a4      # (X(rs1) >> 1) ^ (X(rs1) >> 7)
xor a4, a5, a6      # (X(rs1) >> 8) ^ (X(rs2) << 31)
xor a4, a4, a7      # (X(rs1) >> 8) ^ (X(rs2) << 31) ^ (X(rs2) << 24)
xor a0, a3, a4

loop:
   j loop
