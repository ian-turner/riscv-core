
.text

# testing I-type instructions

addi x1, zero, 832
andi x2, x1, 1583
ori x3, x1, 1853
xori x4, x2, 382
slli x5, x3, 4
srai x6, x3, 8
srli x7, x3, 9

# testing lui instruction (U-type)
lui x8, 1632