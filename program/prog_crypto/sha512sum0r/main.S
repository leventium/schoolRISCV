.text
  li a1, 5
  li a2, 8

  slli s0, a1, 25
  slli s1, a1, 30
  xor s0, s0, s1
  srli s1, a1, 28
  xor s0, s0, s1
  srli s1, a2, 7
  xor s0, s0, s1
  srli s1, a2, 2
  xor s0, s0, s1
  slli s1, a2, 4
  xor a0, s0, s1

end:
  j end