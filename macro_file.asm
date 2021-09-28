# file for macros

# print int with literal value
.macro print_int(%int)
   	li 	$v0, 1			# system call for print integer
   	add 	$a0, $zero, %int	# $a0 = int value
   	syscall				# print integer
.end_macro

# print int with label
.macro print_int2(%int)
   	li 	$v0, 1			# system call for print integer
   	lw 	$a0, %int		# $a0 = integer to print
   	syscall				# print integer
.end_macro

#print char with register
.macro print_char(%char)
   	li	$v0, 11			# system call for print character
   	add 	$a0, $0, %char		# $a0 = char value
   	syscall				# print character
.end_macro

# print str with literal value
.macro print_str(%str)
.data
macro_str:	.asciiz		%str
.text
   	li 	$v0, 4			# system call for print string
	la 	$a0, macro_str		# loads address of null-terminated string to print in $a0
   	syscall				# print string
.end_macro

# print string with label
.macro print_str2(%str)
   	li 	$v0, 4			# system call for print string
   	la 	$a0, %str		# loads address of null-terminated string to print in $a0
   	syscall				# print string
.end_macro

# print string with register
.macro print_str3(%str)
   	li 	$v0, 4			# system call for print string
   	move 	$a0, %str		# $a0 = str value; moves address of null-terminated string to print in $a0
   	syscall				# print string
.end_macro

# get string from user
.macro get_str(%str)
   	li 	$v0, 8			# system call for read string
   	la 	$a0, %str		# loads address of input buffer into $a0
   	li 	$a1, 100		# loads maximum number of characters to read in $a1
   	syscall				# read string
.end_macro

# open the file
.macro open_file(%infile)

   	remove_newLine(%infile)		# delete new line from infile name input
   	
   	# open the file
   	li 	$v0, 13			# system call for open call
   	la 	$a0, %infile		# loads address of null-terminated string containing filename
   	li 	$a1, 0			# loads flag signal (Open for writing (flags are 0: read, 1: write))
   	li 	$a2, 0			# mode is ignored
   	syscall				# open file
   	
   	move 	$s0, $v0		# save the file descriptor; $s0 = $v0
.end_macro

# delete new line from input
.macro remove_newLine(%str)
   	la 	$s3, %str
checkLine:
	# find byte of new line
	lb 	$s4, ($s3)		# load byte of address into register
   	beqz 	$s4, removeLine		# if 0 make take precautions
   	beq 	$s4, 10, removeLine	# if byte is new line, go to label to remove it
   	addi 	$s3, $s3, 1		# increment byte element
   	
   	j 	checkLine		# restart loop for next byte
removeLine:   
	sb 	$0, ($s3)		# zero-out byte - remove new line
.end_macro

# read the file
.macro read_file(%inputBuffer)
	li 	$v0, 14			# system call for read from file
   	move 	$a0, $s0		# move file descriptor value into $a0
   	la 	$a1, %inputBuffer	# load address of input buffer
   	li 	$a2, 1024		# loads maximum number of characters to read
   	syscall				# read from file
   	move 	$s2, $v0		# save content size of file; number of characters read, (0: end-of-file, <0: error)
.end_macro

# close the file
.macro close_file
	li 	$v0, 16  		# system call for close file
   	move 	$a0, $s0		# moves the file descriptor into $a0
   	syscall				# close file
.end_macro

# allocate heap memory
.macro allocate_heap(%heapMemory)
   	li 	$v0, 9			# system command for sbrk (allocate heap memory)
   	li 	$a0, 1024		# load number of bytes to allocate into $a0
   	syscall				# sbrk (allocate heap memory)
   	#move	$s1, $v0
   	sw	$v0, %heapMemory	# save address of allocated memory
.end_macro