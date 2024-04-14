  .text
  li t0, 10
  sw t0, 4
  nop
  nop
  lw a0, 4
  nop
  nop
  li a0, 0

  li t0, -2
  sb t0, 0
  lb a0, 0
  nop
  nop
  lbu a0, 0
loop:
  j loop
