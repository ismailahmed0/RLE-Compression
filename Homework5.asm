# Ismail Ahmed
# CS 2340
# Homework 5
# MIPS Assembly Language Program that implements a compression algorithm - RLE
# Takes an input file from the user and displays its contents, its compressed contents, its uncompressed contents,
# the original file size, and the compressed file size.
# Includes a macros file in the zip.

.include 	"macro_file.asm"

.data
infile:       	.space 		100
buffer:       	.space 		1024
#compBuffer:	.space		1024
dataSize:       .word 		0
newSize:	.word		0
heap:		.word		0

.text
main:   
	# allocate heap memory
	allocate_heap(heap)
  
  	# get file name from user
   	print_str("Enter file name or <enter> to quit: ")	# print literal string value in macro
   	get_str(infile)				# get infile name 
   	print_char('\n')			# print new line
  
   	# check if user entered something for file name
   	lb 	$t0, infile			# load entered value for infile name into register to compare
   	beq 	$t0, '\n', exit			# if user did not enter anything, exit
  
  	# open the file
   	open_file(infile)			# open the file
   	ble 	$s0, $0, error 			# exit if error opening file
   	
   	# analyze the file
   	read_file(buffer)			# read the file
	sw 	$s2, dataSize       		# saves size of content in file
	
	close_file				# close the file
	
	# print uncompressed data
	print_str("Original Content: ")		# print literal string value in macro
	print_char('\n')			# print new line
	print_str2(buffer)			# print label string value in macro
	print_char('\n')			# print new line
	
	# compress data in file
	la	$a0, buffer			# sets $a0 to the address of the input buffer
	#la	$a1, compBuffer			
	lw	$a1, heap			# sets $a1 to the address of the compression buffer
	lw	$a2, dataSize			# sets $a2 to the size of the original file
	#lw	$a3, heap			
  	jal	compressData			# jump to compressData function(label)
  	sw 	$v0, newSize			# save new size that is compressed
	lw 	$t0, heap			# loads into register so can print
	
  	# print compressed data
	print_str("Compressed Content: ")	# print literal string value in macro
	print_char('\n')			# print new line
	print_str3($t0)				# print register string value in macro
	print_char('\n')			# print new line
	
	# print uncompressed data
	print_str("Uncompressed Content: ")	# print literal string value in macro
	print_char('\n')			# print new line
	jal printUncompressed			# goes to printUncompressed function to uncompress and print the content
  	print_char('\n')			# print new line
  	
  	# print original file size
     	print_str("Original file size: ")	# print literal string value in macro
   	print_int2(dataSize)			# print label string value in macro
   	print_char('\n')			# print new line

	# print compressed file size
  	print_str("Compressed file size: ")	# print literal string value in macro
  	print_int2(newSize)			# print label string value in macro
  	print_char('\n')			# print new line
  
  	# clears the buffer
  	li	$t1, 0				# size counter for buffer
  	li	$t2, 0				# buffer index counter
  	jal clearBuffer				# clears the buffer so first "original content" doesn't keep displaying
  	
  	#sw 	$0, buffer			
  	#sb 	$0, buffer
  	
   	j 	main				# restart loop
   	
clearBuffer:
	bge  	$t1, 1024, exitClearBuffer	# if max size reached, go to label 
	
	# clear buffer
	la	$t0, buffer			# load address of buffer into register
	add	$t3, $t0, $t2			# increment address based on index
	#li	$t0, 0
	sb	$0, ($t3)			# store 0 in buffer - clear the buffer
	#addi	$t3, $t3, 1
	
	# incrementations
	addi	$t1, $t1, 4			# increment size counter
	addi	$t2, $t2, 1			# increment array index counter
	
	j 	clearBuffer			# repeat loop for next element in array
	
exitClearBuffer:
  	jr 	$ra				# go back to calling function after calling line
  	
error:
	print_str("Sorry, there was an error.")# error message
	
	j exit					# jump to exit label
	
compressData:
	li	$t0, 0				# index counter: i = 0
	move	$s4, $a0			# $s4 = buffer
	move	$s5, $a1			# $s5 = compressed buffer
	move	$s6, $a2			# $s6 = orginial data size
	li	$t1, 0				# size counter: new compressed data size

loop1:
	bge	$t0, $s6, endCompress		# if i >= size, exit loop, else if i < size continue in loop 
	
	li	$t2, 1				# occurence counter: j = 1
	
loop2:
	# get first byte
	add	$t5, $s4, $t0			# increment address based on index
	lb	$t3, ($t5)			# get first byte
	
	# get subsequent byte
	#bge	$t0, $s6, endCompress		# if i >= size, exit loop, else if i < size continue in loop 
	addi	$t6, $t0, 1			# increment index and store for use for address
	add	$t6, $s4, $t6			# increment address based on index
	#addi	$s4, $s4, 1			# increment address; next value
	lb 	$t4, ($t6)			# get byte after previous byte
	
	
	bne	$t3, $t4, nextChar		# if character is not same as next character go to label; if character same as next character continue
	
	# incrementations
	addi	$t2, $t2, 1			# increment occurence of character counter
	addi	$t0, $t0, 1			# increment index counter
	
	#addi	$s4, $s4, 1			# increment address
	#sll	$s4, $t5, 2
	
	j	loop2				# restart loop for next character

nextChar:
	# store character in heap
	sb	$t3, ($s5)			# store character in heap
	addi	$s5, $s5, 1			# increment address
	addi	$t1, $t1, 1			# increment counter by 1 now since char stored
	
	# determine if number single or double
	li	$t7, 9
	ble	$t2,  $t7, singleBit
	
	# split up number to calculate ASCII 
	li	$t7, 10				# use to convert
	div 	$t2, $t7			# split up the 2 into bits
	
	# first bit stored
	mflo	$t3				# holds value in lo reg
	addi	$t3, $t3, 48			# convert single whole digit part of occurences number to ASCII
	sb	$t3, ($s5)			# value stored in buffer
	#addi	$t1, $t1, 1			# increment counter by 1 now since 1 part of digit stored
	addi	$s5, $s5, 1			# increment address for next bit
	
	# second bit stored
	mfhi	$t3				# holds value in hi reg
	addi	$t3, $t3, 48			# convert single fractional digit part of occurences number to ASCII
	sb	$t3, ($s5)			# value stored in buffer
	#addi	$t1, $t1, 1			# increment counter by 1 now since 1 part of digit stored
	addi	$s5, $s5, 1			# increment address
	
	addi	$t1, $t1, 1			# increment counter by 1 now since 1 byte is completed; 1 byte can store up to 255
	addi	$t0, $t0, 1			# increment index counter
	
	j loop1					# restart loop for next character
	
singleBit:
	# store single bit number
	addi	$t2, $t2, 48			# convert single digit occurences number to ASCII
	sb	$t2, ($s5)			# store occurences of character in heap

	# incrementations
	addi	$t0, $t0, 1			# increment index counter
	addi	$t1, $t1, 1			# increment size counter 2 i.e. A2
	addi	$s5, $s5, 1			# increment address
	
	#sll	$s5, $t5, 2
	
	j	loop1				# restart loop for next character
	
endCompress:
	move	$v0, $t1			# 'return' new size that is compressed
	
	jr	$ra				# go back to calling function after calling line
	
printUncompressed:
	li	$t0, 0				# index counter
	lw	$s4, heap			# load heap into register
	lw	$s5, newSize			# compressed size of content from fle
	#lw	$s6, $a2			# $s6 = orginial data size
	
loop3:
	bge	$t0, $s5, endUncompress		# if i >= size, exit loop, else if i < size continue in loop 

	li	$t1, 0				# # of character(s) printing counter
	
	# get character
	add	$t2, $s4, $t0			# increment address based on index
	lb	$t3, ($t2)			# get first byte
	
	# get ASCII integer
	addi	$t5, $t0, 1			# increment index and store for use for address
	add	$t5, $s4, $t5			# increment address based on index
	lb 	$t4, ($t5)			# get byte after previous byte
	
	# get 3rd character
	addi	$t6, $t0, 2			# increment index and store for use for address
	add	$t6, $s4, $t6			# increment address based on index
	lb 	$t7, ($t6)			# get byte after previous byte
	
	#print_int($t4)
	ble	$t7, 57, doubleBits		# 1st check if 3rd bit is an integer, if so go to doubleBits label
	
	#blt 	$t1, $t4, loop4
	#addi	
	#j loop3
	
singleBits2:
	addi	$t4, $t4, -48			# convert 2nd bit ASCII integer to intger
	
loop4:
	blt 	$t1, $t4, loop5			# if character count less than total characters needing to be printed, go to label
	
	addi	$t0, $t0, 2			# increment index counter
	
	j loop3					# loop again for next byte
loop5:
	print_char($t3)				# print uncompressed byte
	
	addi	$t1, $t1, 1			# increment character counter
	
	j loop4					# loop again and print another same character or move on to the next character
	
doubleBits:
	blt  	$t7, 48, singleBits2		# last check for if 3rd bit is integer; if not go to label
	addi	$t4, $t4, -48			# convert 2nd bit ASCII integer to intger
	addi	$t7, $t7, -48			# convert 3rd bit ASCII integer to intger
	
	#print_int($t4)
	#print_int($t7)
	
	# re-form into integers
	li	$t8, 10				# multiplacation factor
	mul 	$t4, $t8, $t4			# multiply to main
	add	$t4, $t4, $t7			# add onto main
	
	#print_int($t4)
	
	addi	$t0, $t0, 1			# increment index counter here for the 3rd bit which confirmed int
	
	j 	loop4				# go to loop to print character routine
	
endUncompress:
	
	jr 	$ra				# jump to line after function call
	
exit:	
	# terminate the program
	li	$v0, 10				# system call to exit program
	syscall					# exit program