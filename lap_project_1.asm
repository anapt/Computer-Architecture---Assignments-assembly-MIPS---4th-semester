.globl main
.data
  msgprompt: .word msgprompt_data
  msgres1: .word msgres1_data
  msgres2: .word msgres2_data

  msgprompt_data: .asciiz "Please insert an interger number: "
  msgres1_data: .asciiz "The factorial of ("
  msgres2_data: .asciiz ") is: "

# every function call has a stack segment of 8 bytes, or 2 words.
# the space is reserved as follows:
# 0($sp) is reserved for the initial value given to this call
# 4($sp) is the space reserved for the return address.

.text
main:
  # printing the prompt
  #printf("Please insert an interger number: ");
  la      $t0, msgprompt    # load address of msgprompt into $t0
  lw      $a0, 0($t0)       # load data from address in $t0 into $a0
  li      $v0, 4            # call code for print_string
  syscall                   # run the print_string syscall

  # reading the input int
  # scanf("%d", &number);
  li      $v0, 5            # call code for read_int
  syscall                   # run the read_int syscall
  move    $t0, $v0          # store input in $t0

  move    $a0, $t0          # move input to argument register $a0
  addi    $sp, $sp, -8     	# move stackpointer up 2 words
  sw      $t0, 0($sp)       # store input in top of stack
  sw      $ra, 4($sp)       # store counter at bottom of stack
  jal     fact		  		# call factorial

  # when we get here, we have the final return value in $s0


  # printf("The factorial of 'factorial(%d)' is:  %d\n",
  la      $t1, msgres1      # load msgres1 address into $t1
  lw      $a0, 0($t1)       # load msgres1_data value into $a0
  li      $v0, 4            # system call for print_string
  syscall                   # print value of msgres1_data to screen

  lw      $a0, 0($sp)       # load original value into $a0
  li      $v0, 1            # system call for print_int
  syscall                   # print original value to screen

  la      $t2, msgres2      #load msgres2 address into $t1
  lw      $a0, 0($t2)       # load msgres_data value into $a0
  li      $v0, 4            # system call for print_string
  syscall                   # print value of msgres2_data to screen

  move    $a0, $s0        	# move final return value from $s0 to $a0 for return
  li      $v0, 1            # system call for print_int
  syscall                   # print final return value to screen

  addi    $sp, $sp, 8    	# move stack pointer back down where we started

  li      $v0, 10           # system call for exit
  syscall                   # exit!



.text
	fact:
		addi	$sp, $sp, -8 	#adjust stack for 2 items
		sw 		$ra, 4($sp) 	#save return address
		sw 		$a0, 0($sp)		#save argument
		slti	$t0, $a0, 1		#test for n<1
		beq		$t0, $zero, L1
		addi 	$v0, $zero, 1	#if so (t0==0), result is 1
		move 	$s0, $v0		#move result(1) to reg $s0
		addi	$sp, $sp, 8		#pop 2 items from stack
		jr		$ra				#return
		
	L1:
		addi 	$a0, $a0, -1	#if (t0!=0) decrease n
		jal		fact			#recursive call
		lw 		$a0, 0($sp)		#restore original n
		lw		$ra, 4($sp)		#restore original return address
		addi	$sp, $sp, 8		#pop 2 items from stack
		mul 	$v0, $a0, $v0	#multiply to get result
		move	$s0, $v0		#move result to reg $s0
		jr		$ra				#return
		
