######### Computer Organization and Assembly Language Programming - CSCE 2303-01
######### Project 1 - Parser and MIPS Code Generator for sprintf - March 31, 2019
######### Abdelhakim Badawy 900171087 - Marwan Eid 900171885
######### Objective: developing a parser and MIPS code generator for the sprintf function using MARS simulator
######### Input: a string from the user containing the full sprintf function statement
######### Outputs: The converted string with the correct formatted output & the number of characters in the output string
######### sprintf("This is an example of sprintf function statement.\nThe length in decimal = %d while in binary = %b\nThe width in octal = %o while in unsigned decimal = %u\nThe area in uppercase hexadecimal = 0x%X while in lower case hexadecimal = 0x%x\nThe height in octal = %o\nThe Volume in uppercase hexadecimal = 0x%X.", a, a, b, b, c, c, d, e);
######### sprintf("This is an example of \tsprintf function statement.\nThe length in decimal = %d while in binary = %b\nThe width in octal = %o while in unsigned decimal = %u\nThe area in uppercase hexadecimal = 0x%X while in lower case hexadecimal = 0x%x\nThe low byte of the argument d as a character is %c\nThe string pointed to at by argument e is %s.", a, a, b, b, c, c, d, e);
# data segment
.data
prompt1: .asciiz "Please enter the string of the sprintf function statement:\n"
prompt2: .asciiz "\nThe text between quotation is: "
prompt3: .asciiz "\nThe generated text from the sprintf function is:\n"
prompt4: .asciiz "\nThe length of the output string is "
try: .asciiz "try\n"
str: .asciiz "Goodbye."
inputString: .space 1024
formatString: .space 1024
outbuf: .space 1024
result: .space 33
#code segment
.text
.globl main
main:
# Loading initial argument values
	li $t5, -50735 #a
	la $t6, str #b
	la $t7, 75 #c
	li $t8, 0xccccc #d
	li $t9, 0x323D #e
# Print prompt1
	li $v0, 4
	la $a0, prompt1
	syscall
# Get user input and save it in $a1
	la $a0, inputString
	li $a1, 1024
	li $v0, 8
	syscall
# Print prompt2
	li $v0, 4
	la $a0, prompt2
	syscall
# Extracting the text between quotations to formatString and printing it
	la $v0, formatString
	jal parsInput
	move $a1, $v0
	move $a0, $v0
	li $v0, 4
	syscall
# Extracting the arguments
	la $a0, inputString
	jal extractArgs
	la $a0, outbuf
# Printing the generated text from the sprintf function
	jal sprintf
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	li $v0, 4
	la $a0, prompt3
	syscall
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	li $v0, 4
	syscall
# Printing the number of characters in the output string
	li $v0, 4
	la $a0, prompt4
	syscall
	move $a0, $s6
	li $v0, 1
	syscall
# Exiting the program
	li $v0, 10
	syscall

parsInput: # Checks whether we reached the 1st quotation. Start saving characters to the output string just after the 1st quotation and just before the 2nd one
#	li $t0, 0
	li $t2, 0 # counter for the number of characters in the stored output to decrement the pointer by it after reaching the 2nd quotation
	reachQuotation:
		lb $t1, 0($a0)
		bne $t1, '"', noPrint
		addi $a0, $a0, 1
		j checkInput
	noPrint:
		addi $a0, $a0, 1
		j reachQuotation
	checkInput:
		lb $t1, 0($a0)
		beq $t1, '"', secondQuotation
		addi $t2, $t2, 1
		sb $t1, 0($v0)
		addi $v0, $v0, 1
		addi $a0, $a0, 1
		j checkInput
	secondQuotation:
		sub $v0, $v0, $t2
		jr $ra

extractArgs: #Skips until 2nd quotation. Start extracting arguments just after it and just before the closing parenthesis
	li $t0, 0 # counter for quotations mark to indicate when reaching the 2nd quotation
	reachArgs:
		lb $t1, 0($a0)
		beq $t1, '"', foundQuotation
		addi $a0, $a0, 1
		j reachArgs
	foundQuotation:
		bne $t0, $0, prePars
		addi $a0, $a0, 1
		addi $t0, $t0, 1
		j reachArgs
	prePars:
		addi $a0, $a0, 1
		li $t0, 0 # counter for no. of arguments. 1st argument -> $a2. 2nd argument -> $a3. More arguments -> pushed into the stack
	pars:
		lb $t1, 0($a0)
		beq $t1, ')', endParsing
		blt $t1, 97, notArg
		bgt $t1, 101, notArg
		beq $t0, 0, firstArg
		beq $t0, 1, secondArg
		bgt $t0, 1, moreArgs
		bgt $t0, 3, moreArgs
	notArg:
		addi $a0, $a0, 1
		j pars
	firstArg:
		addi $a0, $a0, 1
		addi $t0, $t0, 1
		move $a2, $t1
		j pars
	secondArg:
		addi $a0, $a0, 1
		addi $t0, $t0, 1
		move $a3, $t1
		j pars
	moreArgs:
		addi $a0, $a0, 1
		addi $t0, $t0, 1
		addi $sp, $sp, -4
		sw $t1, 0($sp)
		j pars
	endParsing:
		jr $ra
sprintf: # The function fills the out string pointed to at by $a0 with the correct formatted output string according to the format specifiers in
   	 # the format string, and returns the number of characters in this string.
	li $s6, 0 # counter for number of characters in the output string
	li $t4, 0 # counter for newlines inserted to decrement the pointer to the output string by it before returning from the function
	li $t2, 0 # counter for no. of arguments. 0 -> 1st argument which is in $a2. 1 -> 2nd argument which is in $a3. more than 1 -> more arguments which are stored in the stack
	checkChars: # Checks for current character of the format string. If '%', check for next character and either go to 1 of the 8 formatting
		    # options or saves both characters in the output string if the next character is not 1 of the 8 formatting specifiers.
		    # Stores a new line in output string if the current character and the next character of the format string is '\' and 'n'.
		    # Stores a tab in output string if the current character and the next character of the format string is '\' and 't'.
		    # Otherwise, the character is saved in the output string
		lb $t1, 0($a1)
		beq $t1, $0, endInput
		beq $t1, '%', preCheckFormat
		beq $t1, 92, check4NewLine
		sb $t1, 0($a0)
		addi $s6, $s6, 1
		addi $a1, $a1, 1
		addi $a0, $a0, 1
		j checkChars
	check4NewLine:
		lb $t3, 1($a1)
		beq $t3, 'n', newLine
		beq $t3, 't', TAB
		sb $t1, 0($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $s6, $s6, 1
		j checkChars
	newLine:
		li $t3, 10
		sb $t3, 0($a0)
		addi $a0, $a0, 1
		addi $t4, $t4, 1
		addi $a1, $a1, 2
		j checkChars
	TAB:
		li $t3, '\t'
 		sb $t3, 0($a0)
		addi $a0, $a0, 1
		addi $t4, $t4, 1
		addi $a1, $a1, 2
		j checkChars	
	preCheckFormat:
		beq $t2, $0, fArg
		beq $t2, 1, sArg
		bgt $t2, 1, mArgs
	fArg:
		beq $a2, 'a', argIsA
		beq $a2, 'b', argIsB
		beq $a2, 'c', argIsC
		beq $a2, 'd', argIsD
		beq $a2, 'e', argIsE
	sArg:
		beq $a3, 'a', argIsA
		beq $a3, 'b', argIsB
		beq $a3, 'c', argIsC
		beq $a3, 'd', argIsD
		beq $a3, 'e', argIsE
	mArgs:
# offset = (no. of arguments - current no. of % ) * 4 - remember to decrement the stack by (no. of arguments - 2)*4 when offset = 0
		sub $t1, $t0, $t2
		addi $t1, $t1, -1
		sll $t1, $t1, 2
		add $t1, $t1, $sp
		lb $t1, 0($t1)
		beq $t1, 'a', argIsA
		beq $t1, 'b', argIsB
		beq $t1, 'c', argIsC
		beq $t1, 'd', argIsD
		beq $t1, 'e', argIsE
	argIsA:
		add $s7, $t5, $0
		addi $t2, $t2, 1
		j checkFormat
	argIsB:
		add $s7, $t6, $0
		addi $t2, $t2, 1
		j checkFormat
	argIsC:
		add $s7, $t7, $0
		addi $t2, $t2, 1
		j checkFormat
	argIsD:
		add $s7, $t8, $0
		addi $t2, $t2, 1
		j checkFormat
	argIsE:
		add $s7, $t9, $0
		addi $t2, $t2, 1
		j checkFormat
	checkFormat:
		lb $t3, 1($a1)
		beq $t3, 'd', signedInt2Decimal
		beq $t3, 'u', int2Decimal
		beq $t3, 'b', int2Binary
		beq $t3, 'x', int2lowerHexa
		beq $t3, 'X', int2upperHexa
		beq $t3, 'o', int2octal
		beq $t3, 'c', lowByteChar
		beq $t3, 's', pointer2String
		sb $t1, 0($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $s6, $s6, 1
		j checkChars
	signedInt2Decimal: # Treats the argument as a signed integer and output in decimal 
		li $s1, 10
		la $s4, result
		beq $s7, $0, zero
		blt $s7, 0, negative
		string_adj:
			addi $s4, $s4, 32
			sb $0, 0($s4)
			addi $s4, $s4, -1
		while: 
			beqz $s7, signcheck
			div $s7, $s1
			mfhi $s2
			mflo $s7
			addi $s2, $s2, 48
			sb $s2, 0($s4)
			addi $s4, $s4, -1
			j while
		signcheck:
			beq $s3, 45, printnegative
			beq $s3, 48, printzero
			j printpositive
		copy2out:
			lb $s5, 0($s4)
			beqz $s5, go
			sb $s5, 0($a0)
			addi $a0, $a0, 1
			addi $s4, $s4, 1
			addi $s6, $s6, 1
			j copy2out
		negative:
			li $s3, 45
			neg $s7, $s7
			j string_adj
			j while
		zero: 
			li $s3, 48
			j string_adj
		printnegative:
			sb $s3, 0($s4)
			j copy2out
		printzero:
			sb $s3, 0($s4)
			j copy2out
			
		printpositive: 
			addi $s4, $s4, 1
			j copy2out			
		go:
			addi $a1, $a1, 2
			j checkChars
	int2Decimal:
		li $s1, 10
		li $s2, 48
		la $s3, result
		beqz $s7, zero0
		string_adj0:
			addi $s3, $s3, 32
			sb $0, 0($s3)
			addi $s3, $s3, -1
		while0: 
			beqz $s7, copy2out0
			divu $s7, $s1
			mfhi $s4
			mflo $s7
			add $s4, $s4, $s2
			sb $s4, 0($s3)
			addi $s3, $s3, -1
			j while0
		copy2out0:
			addi $s3, $s3, 1
			lb $s5, 0($s3)
			beqz $s5, go0
			sb $s5, 0($a0)
			addi $a0, $a0, 1
			addi $s6, $s6, 1
			j copy2out0
		zero0: 
			addi $s3, $s3, 1
			sb $0, 0($s3)
			addi $s3, $s3, -1
			sb $s2, 0($s3)
			addi $s3, $s3, -1
			j copy2out0
		go0:
			addi $a1, $a1, 2
			j checkChars
	int2Binary:
		li $s1, 48
		li $s2, 49
		la $s3, result
		string_adj1:
			addi $s3, $s3, 32
			sb $0, 0($s3)
			addi $s3, $s3, -1
			beqz $s7, zero1
		while1:
			beqz $s7, copy2out1
			andi $s4, $s7, 1
			beqz $s4, printzeroo
			sb $s2, 0($s3)
			addi $s3, $s3, -1
			srl $s7, $s7, 1
			j while1
		copy2out1:
			addi $s3, $s3, 1
			lb $s5, 0($s3)
			beqz $s5, go1
			sb $s5, 0($a0)
			addi $a0, $a0, 1
			addi $s6, $s6, 1
			j copy2out1
		zero1: 
			sb $s1, 0($s3)
			addi $s3, $s3, -1
			j copy2out1
		printzeroo:
			sb $s1, 0($s3)
			addi $s3, $s3, -1
			srl $s7, $s7, 1
			j while1
		go1:
			addi $a1, $a1, 2
			j checkChars
	int2lowerHexa:
		li $s1, 48
		li $s2, 49
		la $s3, result
		beqz $s7, zero3
		addi $s3, $s3, 32
		sb $0, 0($s3)
		addi $s3, $s3, -1
		while3:
			beqz $s7, copy2out3
			andi $s4, $s7, 15
			bgt $s4, 9, character
			addi $s4, $s4, 48
			sb $s4, 0($s3)
			addi $s3, $s3, -1
			srl $s7, $s7, 4
			j while3
		copy2out3:
			addi $s3, $s3, 1
			lb $s4, 0($s3)
			beqz $s4, go
			sb $s4, 0($a0)
			addi $a0, $a0, 1
			addi $s6, $s6, 1
			j copy2out3
		zero3: 
			sb $s1, 0($s3)
			addi $s3, $s3, -1
			j copy2out3
		character:
			addi $s4, $s4, 87
			sb $s4, 0($s3)
			addi $s3, $s3, -1
			srl $s7, $s7, 4
			j while3
		go3:
			addi $a1, $a1, 2
			j checkChars
	int2upperHexa: # Treats the argument as an unsigned integer and output in uppercase hexadecimal
		li $s1, 48
		li $s2, 49
		la $s3, result
		beqz $s7, zero3
		addi $s3, $s3, 32
		sb $0, 0($s3)
		addi $s3, $s3, -1
		while4:
			beqz $s7, copy2out4
			andi $s4, $s7, 15
			bgt $s4, 9, character2
			addi $s4, $s4, 48
			sb $s4, 0($s3)
			addi $s3, $s3, -1
			srl $s7, $s7, 4
			j while4
		copy2out4:
			addi $s3, $s3, 1
			lb $s4, 0($s3)
			beqz $s4, go
			sb $s4, 0($a0)
			addi $a0, $a0, 1
			addi $s6, $s6, 1
			j copy2out4
		zero4: 
			sb $s1, 0($s3)
			addi $s3, $s3, -1
			j copy2out4
		character2:
			addi $s4, $s4, 55
			sb $s4, 0($s3)
			addi $s3, $s3, -1
			srl $s7, $s7, 4
			j while4
		go4:
			addi $a1, $a1, 2
			j checkChars
	int2octal:
		li $s1, 48
		la $s2, result
		string_adj5:
			addi $s2, $s2, 32
			sb $0, 0($s2)
			addi $s2, $s2, -1
			beqz $s7, zero5
		while5:
			beqz $s7, copy2out5
			andi $s3, $s7, 7
			addi $s3, $s3, 48
			sb $s3, 0($s2)
			addi $s2, $s2, -1
			srl $s7, $s7, 3
			j while5
		copy2out5:
			addi $s2, $s2, 1
			lb $s4, 0($s2)
			beqz $s4, go5
			sb $s4, 0($a0)
			addi $a0, $a0, 1
			addi $s6, $s6, 1
			j copy2out5
		zero5: 
			sb $s1, 0($s2)
			addi $s2, $s2, -1
			j copy2out5
		go5:
			addi $a1, $a1, 2
			j checkChars
	lowByteChar:
		andi $s0, $s7, 255
		sb $s0, 0($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 2
		addi $s6, $s6, 1
		j checkChars
	pointer2String:
		loop:
		lb $s0, 0($s7)
		beqz $s0, checkChars
		sb $s0, 0($a0)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $s7, $s7, 1
		addi $s6, $s6, 1
		j loop
	endInput:
		sub $a0, $a0, $s6
		sub $a0, $a0, $t4
		jr $ra
