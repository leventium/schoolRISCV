.text
  li a1, 5
  li a2, 8

  slli s0, a1, 23
  srli s1, a1, 14
  xor s0, s0, s1
  srli s1, a1, 18
  xor s0, s0, s1
  srli s1, a2, 9
  xor s0, s0, s1
  slli s1, a2, 18
  xor s0, s0, s1
  slli s1, a2, 14
  xor a0, s0, s1

end:
  j end