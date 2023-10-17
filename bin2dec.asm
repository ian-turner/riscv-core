.text

addi x1, zero, 25		# getting our value for 0.1
slli x1, x1, 8			# this is done by placing each 8 bits and 
				# shifting since the real value is too large
addi x2, zero, 153		
or x1, x1, x2			# <-- second 8 bits
slli x1, x1, 8
or x1, x1, x2			# <-- third 8 bits
slli x1, x1, 8
addi x2, zero, 154
or x1, x1, x2			# <-- fourth 8 bits

addi x5, zero, 10		# setting x5 to 10 to use later
				
addi x2, zero, 1829		# our arbitrary input value
				# (hard-coded for now)

# digit 1
mul x3, x2, x1			# multiply value by 0.1 to get fractional bits

mulhu x2, x2, x1		# getting the hi bits and setting to x2
mulhu x6, x3, x5		# multiply fractional bits by 10 to get number

# digit 2
slli x6, x6, 4
mul x3, x2, x1
mulhu x2, x2, x1
mulhu x7, x3, x5
or x6, x6, x7

# digit 3
slli x6, x6, 4
mul x3, x2, x1
mulhu x2, x2, x1
mulhu x7, x3, x5
or x6, x6, x7

# digit 4
slli x6, x6, 4
mul x3, x2, x1
mulhu x2, x2, x1
mulhu x7, x3, x5
or x6, x6, x7

# digit 5
slli x6, x6, 4
mul x3, x2, x1
mulhu x2, x2, x1
mulhu x7, x3, x5
or x6, x6, x7

# digit 6
slli x6, x6, 4
mul x3, x2, x1
mulhu x2, x2, x1
mulhu x7, x3, x5
or x6, x6, x7

# digit 7
slli x6, x6, 4
mul x3, x2, x1
mulhu x2, x2, x1
mulhu x7, x3, x5
or x6, x6, x7

# digit 8
slli x6, x6, 4
mul x3, x2, x1
mulhu x2, x2, x1
mulhu x7, x3, x5
or x6, x6, x7