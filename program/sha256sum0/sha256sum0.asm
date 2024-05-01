.text
addi a1, zero, 5    # rs1

addi a7, zero, 2
jal ror             # ror32(inb, 2)
add a2, zero, a0

addi a7, zero, 13
jal ror             # ror32(inb, 13)
add a3, zero, a0

addi a7, zero, 22
jal ror             # ror32(inb, 22)
add a4, zero, a0

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
