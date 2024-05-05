.text
addi a1, zero, 5    # rs1
addi a2, zero, 8    # rs2

slli a3, a1, 3      # (X(rs1) << 3)
srli a4, a1, 6      # (X(rs1) >> 6)
srli a5, a1, 19      # (X(rs1) >> 19)

srli a6, a2, 29     # (X(rs2) >> 29)
slli a7, a2, 13     # (X(rs2) << 13)

xor a3, a3, a4      # (X(rs1) << 3) ^ (X(rs1) >> 6)
xor a4, a5, a6      # (X(rs1) >> 19) ^ (X(rs2) >> 29)
xor a4, a4, a7      # (X(rs1) >> 19) ^ (X(rs2) >> 29) ^ (X(rs2) << 13)
xor a0, a3, a4

loop:
   j loop
   
