# Mandelbrot fractal drawing program by Mateusz Osowiecki

	.data
		.space 2
bmpHeader:	.space 54
msg1:		.asciiz "Pass max iteration number:\n"
inFile:		.asciiz "in.bmp"
outFile:		.asciiz "out.bmp"	
	
	.text
main:
	li $v0, 13			# open input file
	la $a0, inFile
	li $a1, 0
	li $a2, 0
	syscall
		
	move $s0, $v0
	
	li $v0, 14			# reading header from input file
	move $a0, $s0
	la $a1, bmpHeader
	li $a2, 54
	syscall
	
	lw $s1, bmpHeader+18		# image width will be stored in $s1
	lw $s2, bmpHeader+22		# image width will be stored in $s2
	lw $s3, bmpHeader+34		# pixel array size stored in $s3
	
	li $v0, 9
	move $a0, $s3
	syscall
	
	move $s4, $v0			# address of input pixel arrray in $s4
	
	li $v0, 16			# close input file
	move $a0, $s0
	syscall
	
	lw $t0, bmpHeader+18
	bne $t0, $s2, end		# if bitmap is not a square then end
	
	li $v0, 4			# pring msg1
	la $a0, msg1
	syscall
	
	li $v0, 5			# read max iteration
	syscall
	move $s0, $v0
	
loopInit:
	li $t0, 0	# height loop iterator	
	li $t2, 2000
	div $s5, $t2, $s1	# coordinate growth per pixel in &s0
	move $s6, $s4
heightLoop:
	li $t1, 0	# width loop iterator
	mul $t7, $t0, $s5	# Py
	addi $t7, $t7, -1000		
widthLoop:
	li $t3, 0	# iteration
	li $t4, 0	# Zr
	li $t5, 0	# Zi
	mul $t6, $t1, $s5	# Px
	addi $t6, $t6, -1000
calculateIteration:
	addi $t3, $t3, 1
	mul $t8, $t4, $t4	# Zr^2
	div $t8, $t8, 1000
	mul $t9, $t5, $t5	# Zi^2
	div $t9, $t9, 1000
	mul $t5, $t4, $t5	# Zr * Zi
	div $t5, $t5, 1000
	mul $t5, $t5, 2		# Zi = 2*Zr*Zi
	sub $t4, $t8, $t9	# Zr = Zr^2-Zi^2
	
	add $t4, $t4, $t6	# Zr = Zr + Px
	add $t5, $t5, $t7	# Zi = Zi + Py
	
	mul $t8, $t4, $t4	# Zr^2
	div $t8, $t8, 1000
	mul $t9, $t5, $t5	# Zi^2
	div $t9, $t9, 1000
	add $t8, $t8, $t9	# Zr^2 + Zi^2
	bge $t8, 4000, paintingPixel	# Zr^2 + Zi^2 < 4
	bge $t3, $s0, paintingPixel
	b calculateIteration	
paintingPixel:
	mul $t8, $t3, 4		# red colour
	li $t9, 256
	div $t8, $t9
	mfhi $t8
	sb $t8, ($s4)
	
	mul $t8, $t3, 28	# green colour
	li $t9, 256
	div $t8, $t9
	mfhi $t8
	sb $t8, 1($s4)
	
	mul $t8, $t3, 52	# blue colour
	li $t9, 256
	div $t8, $t9
	mfhi $t8
	sb $t8, 2($s4)
	
	addi $s4, $s4, 3
	addi $t1, $t1, 1
	blt $t1, $s1, widthLoop
widthLoopEnd:	
	addi $t0, $t0, 1
	blt $t0, $s2, heightLoop
	
saveToOutput:	
	li $v0, 13		# open output file
	la $a0, outFile
	li $a1, 1
	li $a2, 0
	syscall
	
	move $s0, $v0
	
	li $v0, 15		# write header to output file
	move $a0, $s0
	la $a1, bmpHeader
	li $a2, 54
	syscall
	
	li $v0, 15		# write pixel array to output file
	move $a0, $s0
	move $a1, $s6
	move $a2, $s3
	syscall
	
	li $v0, 16		# close output file
	move $a0, $s0
	syscall
end:
	li $v0, 10
	syscall
	
