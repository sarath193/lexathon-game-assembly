getWord:	#Put address of list of 9 char words in $a0
		move $t2, $a0
		
		addi $v0, $0, 42
		addi $a1, $0, 16692	#Random num 0-16691
		syscall
		
		sll $t0, $a0, 3		#Mult by 8
		add $t0, $t0, $a0	#Plus itself again for Mult 9
		
		add $t1, $t0, $t2
		lb $t3, ($t1)
		sb $t3, wordSpace
		lb $t3, 1($t1)
		sb $t3, wordSpace + 1
		lb $t3, 2($t1)
		sb $t3, wordSpace + 2
		lb $t3, 3($t1)
		sb $t3, wordSpace + 3
		lb $t3, 4($t1)
		sb $t3, wordSpace + 4
		lb $t3, 5($t1)
		sb $t3, wordSpace + 5
		lb $t3, 6($t1)
		sb $t3, wordSpace + 6
		lb $t3, 7($t1)
		sb $t3, wordSpace + 7
		lb $t3, 8($t1)
		sb $t3, wordSpace + 8#All of this stores the 9 letter word at wordSpace
		
		jr $ra
		
setMidChar:	addi $v0, $0, 42
		addi $a1, $0, 9	#Random num 0-8 to determine middle character
		syscall
		
		add $t0, $a0, $0
		la $t1, wordSpace
		add $t2, $t0, $t1
		lb $t3, ($t2)
		sb $t3, charmid
		
		la $t5, char1		#This stuff puts the remaining characters in the other char slots
		li $t4, -1		#This counts the character's position in wordSpace
		li $t6, -1		#This counts to determine where the character will be placed
		li $t8, 9
setCharsLoop:	addi $t4, $t4, 1
		beq $t4, $t8, endCharLoop
		beq $t0, $t4, setCharsLoop	#If the counter ($t4) is the same as the random number generated, it skips to the next character
		addi $t6, $t6, 1
		add $t7, $t6, $t5		#Which "char#" space the char goes into
		add $t2, $t1, $t4		#Position in wordSpace
		lb $t3, ($t2)
		sb $t3, ($t7)
		j setCharsLoop
		
endCharLoop:	jr $ra

shuffleChars:	la $t8, char1		#This set of code shuffles char1 - char8

		li $t9, 17		#This will do 18 random shuffles of the characters to try and mix them up as much as possible
		
shufLoop:	addi $t9, $t9, -1
		bltz $t9, endShufLoop	#Ends loop
		
		addi $v0, $0, 42
		addi $a1, $0, 8	
		syscall
		add $t1, $a0, $0	#Two random numbers determining which two chars will switch this iteration
		addi $v0, $0, 42
		addi $a1, $0, 8	
		syscall
		add $t2, $a0, $0
		
		add $t3, $t8, $t1
		add $t4, $t8, $t2	#Gets the address of chars that are switching
		
		lb $t5, ($t3)
		lb $t6, ($t4)
		sb $t5, ($t4)
		sb $t6, ($t3)
		
		j shufLoop

endShufLoop: 	j main
		
