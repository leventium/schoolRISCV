.text
addi a1, zero, 5    # rs1

addi a7, zero, 17
jal ror             # ror32(inb, 17)
add a2, zero, a0

addi a7, zero, 19
jal ror             # ror32(inb, 19)
add a3, zero, a0

srli a4, a1, 10 
xor a0, a2, a3
xor a0, a0, a4

loop:
   j loop
  
ror:
   addi t0, zero, 31
   and t0, t0, a7      # shamt = X(rs2)[4..0]
   srl t2, a1, t0      # (X(rs1) >> shamt)
   
   addi t1, zero, 32   # xlen
   sub t1, t1, t0      # (xlen - shamt)
   sll t1, a1, t1      # (X(rs1) << (xlen - shamt))
   
   or a0, t2, t1
   jr ra
