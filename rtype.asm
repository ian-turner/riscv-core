
.text

addi x1, zero, 1853		# setting some constants to use
addi x2, zero, 1573

# testing R-type instructions

add x3, x2, x1
sub x4, x2, x3
and x5, x4, x1
or x6, x4, x3
xor x7, x3, x5
sll x8, x3, x4
sra x9, x7, x2
srl x10, x4, x8
slt x11, x6, x3
sltu x12, x5, x11
mul x13, x6, x1
mulh x14, x5, x6
mulhu x14, x7, x2
