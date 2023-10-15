.text

addi x1, zero, 409		# getting our value for 0.1
slli x1, x1, 20			# this is done by shifting
				# since the real value is too large

addi x5, zero, 10		# setting x5 to 10 to use later
				
addi x2, zero, 323		# our arbitrary input value
				# hard-coded for now

mul x3, x2, x1			# multiply value by 0.1 to get fractional bits
mulhu x2, x2, x1		# getting the hi bits and setting to x2
mulh x6, x3, x5			# multiply fractional bits by 10 to get number
addi x6, x6, 1			# add 1 (for some reason?)