.globl main

.data 0x10008000
	.word 5, 9, 32
	msgprompt1: .word msgprompt1_data
	msgprompt2: .word msgprompt2_data
	msgres: .word msgres_data
	msscale2: .word msscale2_data
	msscale1: .word msscale1_data

	msgprompt1_data: .asciiz "Select the temperature scale: <c or f>"
	msgprompt2_data: .asciiz "Type the desired temperature: "
	msgres_data: .asciiz "Temperature = "
	msscale2_data: .asciiz " Fahrenheit"
	msscale1_data: .asciiz " Celsius"

.text
main:

  lui		$gp, 0x1000					# the next two lines assign the number 0x10008000 to $gp
  ori		$gp, $gp, 0x8000			# 0x10008000 points to the middle of the static data in memory
  
  #printing the prompt
  #printf("Select the temperature scale: <c or f>");
  la      $t0, msgprompt1   # load address of msgprompt into $t0
  lw      $a0, 0($t0)       # load data from address in $t0 into $a0
  li      $v0, 4            # call code for print_string
  syscall                   # run the print_string syscall
  
  #reading the input int
  #scanf("%d", &character);
  li      $v0, 12           # call code for read_char
  syscall                   # run the read_int syscall
  move    $a1, $v0          # store input in $a1
 
  #printing newline 
  addi $a0, $0, 0xA 		#ascii code for LF
  addi $v0, $0, 0xB 		#syscall 11 prints the lower 8 bits of $a0 as an ascii character.
  syscall
  
  #printing the prompt
  #printf("Type the desired temperature: ");
  la      $t0, msgprompt2   # load address of msgprompt into $t0
  lw      $a0, 0($t0)       # load data from address in $t0 into $a0
  li      $v0, 4            # call code for print_string
  syscall                   # run the print_string syscall
  
  #reading the input float
  #scanf("%d", &number);
  li      $v0, 5            # call code for read_int
  syscall                   # run the read_int syscall
  move	  $t0, $v0			# store input in $f12-- > $t0
  sw	  $t0, 12($gp)
  
  addi 	  $a2, $zero, 99		#reg $a2 == 64 (ascii code for c)
  addi 	  $a3, $zero, 102		#reg $a3 == 70 (ascii code for f)
  
  beq	  $a1, $a2, celsius
  beq	  $a1, $a3, fahrenheit
  
result:
  #when we get here we have the return value stored in $t0
  
  # printf(" Temperature =  ")
  la      $t1, msgres		# load msgres address into $t1
  lw      $a0, 0($t1)       # load msgres_data value into $a0
  li      $v0, 4            # system call for print_string
  syscall                   # print value of msgres1_data to screen
  
  
  move    $a0, $t0        	# move final return value from $s0 to $a0 for return
  li      $v0, 2            # system call for print_float
  syscall                   # print final return value to screen
  
  #checking for scale
  beq	  $a1, $a3, scale1
  beq	  $a1, $a2, scale2

  #printing scale message 
  scale1:
	la      $t1, msscale1	# load msscale1 address into $t1
	lw      $a0, 0($t1)     # load msscale1_data value into $a0
	li      $v0, 4          # system call for print_string
	syscall                 # print value of msscale1_data to screen
	j 		EXIT
	
  scale2:
	la      $t1, msscale2	# load msscale2 address into $t1
	lw      $a0, 0($t1)     # load msscale2_data_data value into $a0
	li      $v0, 4          # system call for print_string
	syscall                 # print value of msscale2_data to screen
	j		EXIT
	
  EXIT:  
	li      $v0, 10           # system call for exit
	syscall                   # exit!

  
#----------------------------------------------------------------------------------------------------------------------
fahrenheit:  
	
	lui		$gp, 0x1000					#the next two lines assign the number 0x10008000 to $gp
	ori		$gp, $gp, 0x8000			# 0x10008000 points to the middle of the static data in memory

	lwc1	$f16, 0($gp)				#moving M[$gp] =5 to $f16
	cvt.s.w	$f16, $f16					#converting the number stored in $f16 to floating point
	
	lwc1	$f18, 4($gp)				#moving M[$gp+4] =9 to $f18
	cvt.s.w	$f18, $f18					#converting the number stored in $f18 to floating point
	
	div.s	$f20, $f16, $f18			#div float point $f16/$f18 and store in $f20 = 5/9

	lwc1	$f14, 8($gp)				#moving M[$gp+8] =32 to $f14	
	cvt.s.w $f14, $f14					#converting the number stored in $f14 to floating point
	
	lwc1 	$f12, 12($gp)				#moving M[$gp+12] to $f12		THIS IS THE USER'S INPUT
	cvt.s.w	$f12, $f12					#converting the number stored in $f12 to floating point

	sub.s	$f12, $f12, $f14			#subtracting $f12=$f12-$f14

	mul.s 	$f12, $f20, $f12			#multiply and store $f12=$f20*$f12 		this is the final result. reg $f12
	
	j	 	result						#return to main program	
	
#----------------------------------------------------------------------------------------------------------------------
celsius:
	
	lui		$gp, 0x1000					#the next two lines assign the number 0x10008000 to $gp
	ori		$gp, $gp, 0x8000			# 0x10008000 points to the middle of the static data in memory
	
	lwc1	$f16, 0($gp)				#moving M[$gp] =5 to $f16
	cvt.s.w	$f16, $f16					#converting the number stored in $f16 to floating point
	
	lwc1	$f18, 4($gp)				#moving M[$gp+4] =9 to $f18
	cvt.s.w	$f18, $f18					#converting the number stored in $f18 to floating point
	
	div.s	$f20, $f18, $f16			#div float point $f18/$f16 and store in $f20 = 9/5
	
	lwc1	$f14, 8($gp)				#moving M[$gp+8] =32 to $f14	
	cvt.s.w $f14, $f14					#converting the number stored in $f14 to floating point
	
	lwc1 	$f12, 12($gp)				#moving M[$gp+12] to $f12			THIS IS THE USER'S INPUT
	cvt.s.w	$f12, $f12					#converting the number stored in $f12 to floating point
	
	mul.s 	$f12, $f20, $f12			# multiply and store $f12 = temp * 9/5
	
	add.s	$f12, $f12, $f14			#add 32 and store. this is the final result. reg $12
	
	j 		result						#return to main program	
	
	