.data
	#declare space and initialize to zero the tictac data array & and the array to be used in the move selection algorithm
	TicTacArray: 	.word 0:9
	calcArray: 	.word 0:9 
	#1 = User 10 = Computer
	#initial promt to start game
	initPrompt: 	.asciiz "Starting Tic-Tac-Toe User = X \n [_|_|_] Select   [0|1|2]\n [_|_|_] a number [3|4|5]\n [_|_|_]          [6|7|8]\n"
	#texts to show user their input
	newLine: 	.asciiz "\n"
	enterInput: 	.asciiz "Enter selection: "
	inputRecived: 	.asciiz "Move selected: "
	drawMessage:	.asciiz "the game has ended in a draw\n"
	userWinMessage:	.asciiz "You won!\n"
	compWinMessage:	.asciiz "You lost, better luck next time\n"
	#texts to display game board
	currentBoard: 	.asciiz "Current Tic-Tac-Toe board: \n"
	# User input board
	row1: .asciiz " Select   [0|1|2]\n"
	row2: .asciiz " a number [3|4|5]\n"
	row3: .asciiz "          [6|7|8]\n"
	# 1 x
	TXFF: .asciiz "[X|_|_]"
	TFXF: .asciiz "[_|X|_]"
	TFFX: .asciiz "[_|_|X]"
	# 1 o
	TOFF: .asciiz "[O|_|_]"
	TFOF: .asciiz "[_|O|_]"
	TFFO: .asciiz "[_|_|O]"
	# 2 X
	TXXF: .asciiz "[X|X|_]"
	TXFX: .asciiz "[X|_|X]"
	TFXX: .asciiz "[_|X|X]"
	# 3 x
	TXXX: .asciiz "[X|X|X]"
	# 2 o
	TOOF: .asciiz "[O|O|_]"
	TOFO: .asciiz "[O|_|O]"
	TFOO: .asciiz "[_|O|O]"
	# 3 o
	TOOO: .asciiz "[O|O|O]"
	# 3 F
	TFFF: .asciiz "[_|_|_]"
	# 1 o & 1 x
	TXOF: .asciiz "[X|O|_]"
	TXFO: .asciiz "[X|_|O]"
	
	TOXF: .asciiz "[O|X|_]"
	TFXO: .asciiz "[_|X|O]"
	TFOX: .asciiz "[_|O|X]"
	TOFX: .asciiz "[O|_|X]"
	# 2 o & 1 x
	TXXO: .asciiz "[X|X|O]"
	TXOX: .asciiz "[X|O|X]"
	TOXX: .asciiz "[O|X|X]"
	# 1 o & 2 x
	TOOX: .asciiz "[O|O|X]"
	TOXO: .asciiz "[O|X|O]"
	TXOO: .asciiz "[X|O|O]"
	
	
	
	
	
	.text	
	.globl main
main:
	addi	$t9,$zero 5	#draw check if five computer moves have occured then draw
	#output the initial prompt for the user to make first move
	li 	$v0, 4 	#tell the computer we are going to print text
	la 	$a0, initPrompt 	#load the prompt into the memory
	syscall 	#display the prompt text
	#set the init values of variables to be used to zero
	addi	$s1, $zero, 0 	#display loop iterations
	addi	$s2, $zero, 0	#array element one value
	addi	$s3, $zero, 0	#array element two value
	addi	$s4, $zero, 0	#array element three value
	addi	$s5, $zero, 0	#array element one position - location of s2
	addi	$s6, $zero, 0	#array element two position - location of s3
	addi	$s7, $zero, 0	#array element three position - location of s4
	b Loop

	####   begin game loop  ####
Loop:
	#get the move from user
	li 	$v0, 4 		#tell the computer we are going to print text
	la 	$a0, enterInput	#load the prompt into the memory
	syscall 		#display the prompt text
	li 	$v0, 5 		#tell computer we want to get an integer from user
	syscall 		#retrieve the user input

	#store the input from the user
	move 	$t0, $v0	
	sll	$t1, $t0, 2		#multiply the user input by four (2^2) to get the array address
	#add users pick to Tac array
	addi	$t0, $zero, 1		#set t0 to 1
	sw 	$t0, TicTacArray($t1) 	#save the move in the TicTacArray
	
	# Show the users input
	li 	$v0, 4		#tell computer we want to output text (output the state of the array)
	la 	$a0, inputRecived	
	syscall 
	li 	$v0, 1		#tell computer we want to output an integer	
	move 	$a0, $t0	#output the integer the user inpurted
	syscall
	li 	$v0, 4	#tell computer we want to output text (output the state of the array)
	la 	$a0, newLine
	syscall 
	
	#check if the user won 
	jal 	checkWin
	
	#use s0 to ensure there are still moves available
	move 	$s0, $zero	# for every free block encountered one will be added to s0 since the same block can be counted 3 time shift right logical is used
	#### Algorithm Logic
	jal 	algorithmLogic
	
	#make the move based of the values
	jal  	movePick

	#check to see if win has occured
	jal checkWin	# if win is true the program will be ended by checkOOO

	####

	
		
	#-> call displayLoop
	jal 	displayLoop
	#-> call checkWin 
	subi	$t9, $t9, 1
	bne 	$t9, $zero, Loop
	j 	draw	#if four move then game is over
	#### end of game loopc ode ####	
	
		
	### algoritmLogic
algorithmLogic:
		#this function will use the TicTacToe array to populate the calcArray with the values of each move option
		# value is calculated as the number of potential wins +1 if it will block the user ++3 if it will prevent the user from winning +4 if it is a win
		# for factoring the block value use functions check block and check win
		#store the current value of of $ra into t4 to save it so that the function can return to the proper address
		add	$t4, $ra, $zero
		#reset the calc array values to zero
		move	$t7, $zero
		move	$t2, $zero
		sw	$t7, calcArray($t2)	# reset calc array element 1
		addi	$t2, $t2, 4
		sw	$t7, calcArray($t2)	# reset calc array element 2
		addi	$t2, $t2, 4
		sw	$t7, calcArray($t2)	# reset calc array element 3
		addi	$t2, $t2, 4
		sw	$t7, calcArray($t2)	# reset calc array element 4
		addi	$t2, $t2, 4
		sw	$t7, calcArray($t2)	# reset calc array element 5
		addi	$t2, $t2, 4
		sw	$t7, calcArray($t2)	# reset calc array element 6
		addi	$t2, $t2, 4
		sw	$t7, calcArray($t2)	# reset calc array element 7
		addi	$t2, $t2, 4
		sw	$t7, calcArray($t2)	# reset calc array element 8
		addi	$t2, $t2, 4
		sw	$t7, calcArray($t2)	# reset calc array element 9
		
		#calc the top cross
		jal 	varTopCross	#get the values for the top cross calculation s2-4 are the values s5-s7 are the array positions
		jal 	logicElementValue
		#calc the mid cross
		jal 	varMidCross	#get the values for the mid cross calculation s2-4 are the values s5-s7 are the array positions
		jal 	logicElementValue
		#calc the bottom cross	
		jal 	varBottomCross	#get the values for the bottom cross calculation s2-4 are the values s5-s7 are the array positions
		jal 	logicElementValue
		#calc the left vert
		jal 	varLeftVert	#get the values for the left vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	logicElementValue
		#calc the mid vert
		jal 	varMidVert	#get the values for the mid vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	logicElementValue
		#calc the right vert	
		jal 	varRightVert	#get the values for the right vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	logicElementValue
		#calc the left diagonal
		jal 	varLeftDiag	#get the values for the mid vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	logicElementValue
		#calc the right diagonal
		jal 	varRightDiag	#get the values for the right vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	logicElementValue
		
		jr	$t4
	
	movePick:
	#the move will be the element in calc array with the greatest value
		#first initialize the element with greatest value to be the first element in calc array and save its position
		#next iterate through calc Array and replace the greatest element if it is lest then the current element in the iteration
		#return the position of the greatest element
		#set the value of TicTacArray at the position with the greatest value to 10
		add	$t4, $ra, $zero
		addi	$t0, $zero, 0		#reset $t0 because it was used in saveing the user input and will cause a word alighnment error if the first element is largest 
		#this function find the largest value in the calc array and takes that move then checks to make sure there is a win
		addi 	$s4, $zero, 0		#set the incrementor to zero
		lw 	$t1, calcArray($s4)	#get first value to store as largest in $t1
		addi	$s4, $s4, 1		#increment the element position to start at one 
		jal increArray
		# the first largest value position in the array- the optimal move - is in $t0
		addi	$t7, $zero, 10		#set t7 to 10
		sw 	$t7, TicTacArray($t0) 	#save the move in the TicTacArray	
		jr	$t4			#return to game loop
	increArray:
		#this is the inner loop logic for parsing the array
		#first increment s4 to get address of current element s4 and place in t2
		#then use the address in t2 to get the value of the element and place in t3
		# if the current largest element t1 is less than new element t3 then call newLargest
		# else 
		#now t2 is free to be used to check that the incrementor is less then 9 - the array size
		#if the incrementor does not equal nine increArray will call itself
		#else return to move pick
		sll	$t2, $s4, 2		#use incrementor to get address of the next element to compare
		addi	$s4, $s4, 1		#increment the element position
		lw 	$t3, calcArray($t2)	# use the address in t2 to get value of the element in the array
		blt	$t1, $t3, newLargest
	
		addi	$t2, $zero, 8		# use t2 to check that the loop hasnt iterated 9 times
		bne	$s4, $t2, increArray
		jr	$ra
	newLargest:
		#t2 contains the address of the new largest
		#t3 contains the value of the new largest
		# we will move the value of the new largest to t0 and t1 respectively 
		#then increment the incrementor/element position
		#now t2 is free to be used to check that the incrementor is less then 9 - the array size
		#if the incrementor does not equal nine increArray will be called
		#else return to move pick
		move 	$t1, $t3	#set the largest value to t1 
		move	$t0, $t2	#set the largest values position to t0
		addi	$t2, $zero, 8	# use t2 to check that the loop hasnt iterated 9 times
		bne	$s4, $t2, increArray
		jr	$ra
		
	### logic to store the var values used in calculating the optimum move
	varTopCross:
		move 	$t2, $zero
		#compare values
		lw 	$s2, TicTacArray($t2)  #set s2 to array element 
		addi	$t2, $t2, 4
		lw 	$s3, TicTacArray($t2)
		addi	$t2, $t2, 4
		lw 	$s4, TicTacArray($t2)
		#array positions
		addi 	$s5, $zero, 0
		addi 	$s6, $zero, 4
		addi 	$s7, $zero, 8
		jr 	$ra
		
	varMidCross:
		addi 	$t2, $zero, 12
		#compare values
		lw 	$s2, TicTacArray($t2)	#set s2 to array element 
		addi	$t2, $t2, 4
		lw 	$s3, TicTacArray($t2)
		addi	$t2, $t2, 4
		lw 	$s4, TicTacArray($t2)
		#array positions
		addi 	$s5, $zero, 12
		addi 	$s6, $zero, 16
		addi 	$s7, $zero, 20
		jr 	$ra
	
	varBottomCross:
		addi 	$t2, $zero, 24
		#compare values
		lw 	$s2, TicTacArray($t2)	#set s2 to array element 
		addi	$t2, $t2, 4
		lw 	$s3, TicTacArray($t2)
		addi	$t2, $t2, 4
		lw 	$s4, TicTacArray($t2)
		#array positions
		addi 	$s5, $zero, 24
		addi 	$s6, $zero, 28
		addi 	$s7, $zero, 32
		jr 	$ra
	
	varLeftVert:
		addi 	$t2, $zero, 0
		#compare values
		lw 	$s2, TicTacArray($t2)	#set s2 to array element 
		addi	$t2, $t2, 12
		lw 	$s3, TicTacArray($t2)
		addi	$t2, $t2, 12
		lw 	$s4, TicTacArray($t2)
		#array positions
		addi 	$s5, $zero, 0
		addi 	$s6, $zero, 12
		addi 	$s7, $zero, 24
		jr 	$ra
		
	varMidVert:
		addi 	$t2, $zero, 4
		#compare values
		lw 	$s2, TicTacArray($t2)	#set s2 to array element 
		addi	$t2, $t2, 12
		lw 	$s3, TicTacArray($t2)
		addi	$t2, $t2, 12
		lw 	$s4, TicTacArray($t2)
		#array positions
		addi 	$s5, $zero, 4
		addi 	$s6, $zero, 16
		addi 	$s7, $zero, 28
		jr 	$ra
	
	varRightVert:
		addi 	$t2, $zero, 8
		#compare values
		lw 	$s2, TicTacArray($t2)	#set s2 to array element 
		addi	$t2, $t2, 12
		lw 	$s3, TicTacArray($t2)
		addi	$t2, $t2, 12
		lw 	$s4, TicTacArray($t2)
		#array positions
		addi	$s5, $zero, 8
		addi	$s6, $zero, 20
		addi 	$s7, $zero, 32
		jr 	$ra
	
	varLeftDiag:
		addi 	$t2, $zero, 0
		#compare values
		lw 	$s2, TicTacArray($t2)	#set s2 to array element 
		addi	$t2, $t2, 16
		lw 	$s3, TicTacArray($t2)
		addi	$t2, $t2, 16
		lw 	$s4, TicTacArray($t2)
		#array positions
		addi 	$s5, $zero, 0
		addi 	$s6, $zero, 16
		addi 	$s7, $zero, 32
		jr 	$ra
	
	varRightDiag:
		addi 	$t2, $zero, 8
		#compare values
		lw 	$s2, TicTacArray($t2) #set s2 to array element 
		addi	$t2, $t2, 8
		lw 	$s3, TicTacArray($t2)
		addi	$t2, $t2, 8
		lw 	$s4, TicTacArray($t2)
		#array positions
		addi 	$s5, $zero, 8
		addi 	$s6, $zero, 16
		addi 	$s7, $zero, 24
		jr 	$ra
		
	logicElementValue:
		 #s2-4 are the values s5-s7 are the array positions
		 # if s2 s3 and s4 are all 0 add one to each in calcArray
		beq 	$s2, $zero, calcF
		beq	$s2, 1, calcX
		beq	$s2, 10, calcO
		# function will return from one of the branches - all conditions are accounted
		
			
		
		
	### display Tic Tac toe board Logic
	displayLoop:
			#Current board is stored in the TicTacArray	
			#display loop calls row out three times using 
			#	the TicTacArray the iterations are:
			#	iteration one - first row - array elements   1,2,3
			#	iteration two - second row - array elements  4,5,6
			#	iteration three - third row - array elements 7,8,9
			
		#store the current value of of $ra into t4 to save it so that the function can return to the proper address
		add	$t4, $ra, $zero
		
		# User input board
		#row1: .asciiz " Select   [0|1|2]"
		#row2: .asciiz " a number [3|4|5]"
		#row3: .asciiz "          [6|7|8]"
		
		jal 	varTopCross
		jal 	rowOut
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, row1	#load the prompt into the memory
		syscall 		#display the prompt text
		jal 	varMidCross
		jal 	rowOut
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, row2	#load the prompt into the memory
		syscall 		#display the prompt text
		jal	varBottomCross
		jal 	rowOut
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, row3	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$t4
	#function to display row
	rowOut: 
		#1 = User 10 = Computer
		# S5 S6 S7 have the values for the rows from left to right
		#determin if s5 is X O or free
		beq	$s2, $zero, F
		beq	$s2, 1, X
		beq	$s2, 10, O
		#jr	$ra this command is unnecesary bc the beq path will handle all cases
	X:	
		beq	$s3, 0, XF
		beq	$s3, 1, XX
		beq	$s3, 10, XO

	O:
		beq	$s3, 0, OF
		beq	$s3, 1, OX
		beq	$s3, 10, OO

	F:
		beq	$s3, 0, FF
		beq	$s3, 1, FX
		beq	$s3, 10, FO

	XX:
		beq	$s4, 0, XXF
		beq	$s4, 1, XXX
		beq	$s4, 10, XXO

	XO:
		beq	$s4, 0, XOF
		beq	$s4, 1, XOX
		beq	$s4, 10, XOO

	XF:
		beq	$s4, 0, XFF
		beq	$s4, 1, XFX
		beq	$s4, 10, XFO

	OX:
		beq	$s4, 0, OXF
		beq	$s4, 1, OXX
		beq	$s4, 10, OXO

	OO:
		beq	$s4, 0, OOF
		beq	$s4, 1, OOX
		beq	$s4, 10, OOO

	OF:
		beq	$s4, 0, OFF
		beq	$s4, 1, OFX
		beq	$s4, 10, OFO

	FX:
		beq	$s4, 0, FXF
		beq	$s4, 1, FXX
		beq	$s4, 10, FXO

	FO:
		beq	$s4, 0, FOF
		beq	$s4, 1, FOX
		beq	$s4, 10, FOO

	FF:
		beq	$s4, 0, FFF
		beq	$s4, 1, FFX
		beq	$s4, 10, FFO

	XXX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXXX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	XXO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXXO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	XXF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXXF	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	XOX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXOX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	XOO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXOO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	XOF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXOF	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	XFX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXFX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	XFO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXFO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	XFF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TXFF	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OXX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOXX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OXO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOXO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OXF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOXF	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OOX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOOX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OOO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOOO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OOF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOOF	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OFX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOFX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OFO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOFO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	OFF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TOFF	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra	
	FXX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFXX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	FXO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFXO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	FXF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFXF	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra		
	FOX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFOX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	FOO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFOO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	FOF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFOF	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	FFX:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFFX	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	FFO:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFFO	#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	FFF:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, TFFF#load the prompt into the memory
		syscall 		#display the prompt text
		jr	$ra
	
	###
	
	calcX:	
		beq	$s3, 0, calcXF
		beq	$s3, 1, calcXX
		beq	$s3, 10, calcXO

	calcO:
		beq	$s3, 0, calcOF
		beq	$s3, 1, calcOX
		beq	$s3, 10, calcOO

	calcF:
		beq	$s3, 0, calcFF
		beq	$s3, 1, calcFX
		beq	$s3, 10, calcFO

	calcXX:
		beq	$s4, 0, calcXXF
		beq	$s4, 1, checkXXX	#check user win
		beq	$s4, 10, calcXXO

	calcXO:
		beq	$s4, 0, calcXOF
		beq	$s4, 1, calcXOX
		beq	$s4, 10, calcXOO

	calcXF:
		beq	$s4, 0, calcXFF
		beq	$s4, 1, calcXFX
		beq	$s4, 10, calcXFO

	calcOX:
		beq	$s4, 0, calcOXF
		beq	$s4, 1, calcOXX
		beq	$s4, 10, calcOXO

	calcOO:
		beq	$s4, 0, calcOOF
		beq	$s4, 1, calcOOX
		beq	$s4, 10, checkOOO 	#this shouldnt happen till after movepick

	calcOF:
		beq	$s4, 0, calcOFF
		beq	$s4, 1, calcOFX
		beq	$s4, 10, calcOFO

	calcFX:
		beq	$s4, 0, calcFXF
		beq	$s4, 1, calcFXX
		beq	$s4, 10, calcFXO

	calcFO:
		beq	$s4, 0, calcFOF
		beq	$s4, 1, calcFOX
		beq	$s4, 10, calcFOO

	calcFF:
		beq	$s4, 0, calcFFF
		beq	$s4, 1, calcFFX
		beq	$s4, 10, calcFFO

	checkXXX:#check for a computer win
		bne	$s2, 1, return
		bne	$s3, 1, return
		bne	$s4, 1, return
		b	userWin	
		#all return conditions accounted
	calcXXO:#no change
		jr	$ra
	calcXXF:#mark F as a block
		lw	$t7, calcArray($s7)
		addi	$t7, $t7, 10
		sw	$t7, calcArray($s7)
		jr	$ra
	calcXOX:#no change
		jr	$ra
	calcXOO:#no change
		jr	$ra
	calcXOF:#no change
		jr	$ra
	calcXFX:#mark F as a block
		
		lw	$t7, calcArray($s6)
		addi	$t7, $t7, 10
		sw	$t7, calcArray($s6)
		jr	$ra
	calcXFO:#no change

		jr	$ra
	calcXFF:#add one to _FF
		addi	$s0, $s0, 2 	#tell computer there is a free block to maintain draw logic
		lw	$t7, calcArray($s6) 	#load value of calc array at s6 into t7
		addi	$t7, $t7, 1		#add 1 to the value of calc array at s6
		sw	$t7, calcArray($s6)	#save value of calc array s6++
		
		lw	$t7, calcArray($s7)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s7)
		jr	$ra
	calcOXX:#no change
		jr	$ra
	calcOXO:#no change
		jr	$ra
	calcOXF:#no change
		
		jr	$ra
	calcOOX:#no change
		jr	$ra
	checkOOO: #check for a computer win
		bne	$s2, 10, return
		bne	$s3, 10, return
		bne	$s4, 10, return
		b	computerWin	
		#all return conditions accounted
	calcOOF:#mark F as a winning value
		lw	$t7, calcArray($s7)
		addi	$t7, $t7, 100
		sw	$t7, calcArray($s7)
		jr	$ra
	calcOFX:#no change
		jr	$ra
	calcOFO:#mark F as a winning value
		lw	$t7, calcArray($s6)
		addi	$t7, $t7, 100
		sw	$t7, calcArray($s6)
		jr	$ra
	calcOFF: #add one to _FF
		lw	$t7, calcArray($s6)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s6)
		lw	$t7, calcArray($s7)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s7)
		jr	$ra	
	calcFXX: #mark F as a block
		lw	$t7, calcArray($s5)
		addi	$t7, $t7, 10
		sw	$t7, calcArray($s5)
		jr	$ra
	calcFXO:# no change
		jr	$ra
	calcFXF:#add one to F_F
		lw	$t7, calcArray($s5)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s5)
		
		lw	$t7, calcArray($s7)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s7)
		jr	$ra		
	calcFOX: # no change
		jr	$ra
	calcFOO: #mark F as a winning value
		addi	$s0, $s0, 1 	#tell computer there is a free block to maintain draw logic
		lw	$t7, calcArray($s5)
		addi	$t7, $t7, 100
		sw	$t7, calcArray($s5)
		jr	$ra
	calcFOF:#add one to F_F
		addi	$s0, $s0, 2 	#tell computer there is a free block to maintain draw logic
		lw	$t7, calcArray($s5)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s5)
		lw	$t7, calcArray($s7)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s7)
		jr	$ra
	calcFFX:# add one to FF
		addi	$s0, $s0, 2 	#tell computer there is a free block to maintain draw logic
		lw	$t7, calcArray($s5)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s5)
		lw	$t7, calcArray($s6)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s6)
		jr	$ra
	calcFFO: # add one to FF
		addi	$s0, $s0, 2 	#tell computer there is a free block to maintain draw logic
		lw	$t7, calcArray($s5)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s5)
		lw	$t7, calcArray($s6)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s6)
		jr	$ra
	calcFFF: #add one to each element
		addi	$s0, $s0, 3 	#tell computer there is a free block to maintain draw logic
		lw	$t7, calcArray($s5)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s5)
		lw	$t7, calcArray($s6)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s6)
		lw	$t7, calcArray($s7)
		addi	$t7, $t7, 1
		sw	$t7, calcArray($s7)
		jr	$ra
	
	return:
		jr $ra
	checkWin:
		add	$t4, $ra, $zero
		#calc the top cross
		jal 	varTopCross	#get the values for the top cross calculation s2-4 are the values s5-s7 are the array positions
		jal 	checkXXX
		jal	checkOOO
		#calc the mid cross
		jal 	varMidCross	#get the values for the mid cross calculation s2-4 are the values s5-s7 are the array positions
		jal 	checkXXX
		jal	checkOOO
		#calc the bottom cross	
		jal 	varBottomCross	#get the values for the bottom cross calculation s2-4 are the values s5-s7 are the array positions
		jal 	checkXXX
		jal	checkOOO
		#calc the left vert
		jal 	varLeftVert	#get the values for the left vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	checkXXX
		jal	checkOOO
		#calc the mid vert
		jal 	varMidVert	#get the values for the mid vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	checkXXX
		jal	checkOOO
		#calc the right vert	
		jal 	varRightVert	#get the values for the right vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	checkXXX
		jal	checkOOO
		#calc the left diagonal
		jal 	varLeftDiag	#get the values for the mid vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	checkXXX
		jal	checkOOO
		#calc the right diagonal
		jal 	varRightDiag	#get the values for the right vert calculation s2-4 are the values s5-s7 are the array positions
		jal 	checkXXX
		jal	checkOOO
		
		jr	$t4
	
	userWin:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, userWinMessage	#load the prompt into the memory
		syscall 		#display the prompt text
		jal 	displayLoop
		b 	End
	computerWin:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, compWinMessage	#load the prompt into the memory
		syscall 	#display the prompt text
		jal 	displayLoop
		b 	End
	draw:
		li 	$v0, 4 		#tell the computer we are going to print text
		la 	$a0, drawMessage	#load the prompt into the memory
		syscall 		#display the prompt text
		jal 	displayLoop
		b 	End
	
	End: #jump to end of the program
	
