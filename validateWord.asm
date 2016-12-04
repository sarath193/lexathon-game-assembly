usesChars:	#Checks to see if the word is of length 4-9, if it uses the correct characters, and if the mid char is used.
		#Load address of string into $a0. Returns $v0 = 0 if false and 1 if true
		li $t0, 0
		sb $t0, charUsed
		sb $t0, charUsed + 1
		sb $t0, charUsed + 2
		sb $t0, charUsed + 3
		sb $t0, charUsed + 4		#These values will be used to check to see if a character was used
		sb $t0, charUsed + 5
		sb $t0, charUsed + 6
		sb $t0, charUsed + 7
		sb $t0, charUsed + 8
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		move $t0, $a0
		li $v0, -1
		jal stringLength
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		move $t0, $v0		#t1 contains the string length
		
		li $t1, 4
		blt $t0, $t1, invalidLength	#Makes sure word is greater than or equal to 4
		li $t1, 9
		blt $t1, $t0, invalidLength	#Makes sure the word is less than or equal to 9
		move $s1, $t0
					#t1 will be used to count and check for each character 8->0
					#t0 will be subtracted and the loop will end once it is below 0
		la $t9, char1
		la $t8, charUsed
		
checkLoop1:	addi $t0, $t0, -1
		bltz $t0, endCheck
		add $t2, $t0, $a0	#Get the byte at address t2 which is a character in the input
		lb $t3, ($t2)		#t3 contains the first byte that will be checked
		li $t1, 9
checkLoop2:	addi $t1, $t1, -1
		ble $t1, -1, invalidChar	#If this loop reaches the end without finding a character that hasn't been used, 
						#then that means an invalid one was used.
		add $t5, $t8, $t1	#Gets address of the byte used to check if a character is used
		lb $t7, ($t5)
		bnez $t7, checkLoop2	#If the character was already used, skips to next character
		add $t4, $t9, $t1	#Gets address of the character being checked
		lb $t6, ($t4)
		beq $t3, $t6, correctChar
		j checkLoop2
		
correctChar:	#Sets the bool (charUsed) for that char to 1 if it was used
		li $t2, 1
		sb $t2, ($t5)	#Stores a 1 in the bool byte for the character found
		j checkLoop1


endCheck:	li $t2, 8
		add $t2, $t2, $t8	#Gets address of the midChar's bool byte
		lb $t3, ($t2)
		beqz $t3, needMid
		li $v0, 1		#If it gets this far, the word correctly uses the characters!
		jr $ra


stringLength:			#Gets the length of the string at $a0 and make sure $v0 is 0
		
		lb $t1, 0($t0)		#Loads the character into the byte ($t0 changes)
		beqz $t1, endLenLoop		#Ends loop if it reaches the null terminator
		addi $t0, $t0, 1	#Moves the address
		addi $v0, $v0, 1	#$t2 counts the length of the string
		j stringLength
		
endLenLoop:	
		jr $ra

correctWord:	#Go here if a word was correct and add to the score
		lw $t0, score
		addi $t0, $t0, 5	#Adds 5 to the score
		add $t0, $t0, $s1	#Adds the length of the word to the score  
		sw $t0, score
		
		lw $t0, wordsFound
		la $t1, foundList
		sll $t2, $t0, 3
		add $t2, $t0, $t2	#Mult by 9 for spacing the words found
		add $t1, $t2, $t1
		
		lb $t4, userIn
		sb $t4, ($t1)
		lb $t4, userIn + 1
		sb $t4, 1($t1)
		lb $t4, userIn + 2
		sb $t4, 2($t1)
		lb $t4, userIn + 3
		sb $t4, 3($t1)
		lb $t4, userIn + 4
		sb $t4, 4($t1)
		lb $t4, userIn + 5
		sb $t4, 5($t1)
		lb $t4, userIn + 6
		sb $t4, 6($t1)
		lb $t4, userIn + 7
		sb $t4, 7($t1)
		lb $t4, userIn + 8
		sb $t4, 8($t1)
		
		
		addi $t0, $t0, 1
		sw $t0, wordsFound	#Increases words found
		####Put text about correct word entered here####
		j addTime

checkUsed:	la $t0, ($a0)
		la $t1, foundList
		li $t2, -1
		lw $t3, wordsFound
checkUsedLoop:	
		addi $t2, $t2, 1
		bge $t2, $t3, notFound
		sll $t4, $t2, 3
		add $t4, $t2, $t4
		add $t4, $t1, $t4
		lb $t5, userIn
		lb $t6, ($t4)
		bne $t5, $t6, checkUsedLoop
		lb $t5, userIn + 1
		lb $t6, 1($t4)
		bne $t5, $t6, checkUsedLoop
		lb $t5, userIn + 2
		lb $t6, 2($t4)
		bne $t5, $t6, checkUsedLoop 
		lb $t5, userIn + 3
		lb $t6, 3($t4)
		bne $t5, $t6, checkUsedLoop 
		lb $t5, userIn + 4
		lb $t6, 4($t4)
		bne $t5, $t6, checkUsedLoop 
		lb $t5, userIn + 5
		lb $t6, 5($t4)
		bne $t5, $t6, checkUsedLoop 
		lb $t5, userIn + 6
		lb $t6, 6($t4)
		bne $t5, $t6, checkUsedLoop 
		lb $t5, userIn + 7
		lb $t6, 7($t4)
		bne $t5, $t6, checkUsedLoop 
		lb $t5, userIn + 8
		lb $t6, 8($t4)
		bne $t5, $t6, checkUsedLoop
		
		li $v0, 0	#If it reaches this far, then that means that it was found in here and was previously used
		jr $ra
		
notFound:	li $v0, 1
		jr $ra

invalidLength:	####Print text here about the word being the wrong length
		la $a0, badLength
		addi $v0, $0, 4
		syscall			
		li $v0, 0
		jr $ra
		
invalidChar:	####Print text here about the word using the wrong characters
		la $a0, badChar
		addi $v0, $0, 4
		syscall		
		li $v0, 0
		jr $ra
		
needMid:	####Print text here about the word not using the mid charactr
		la $a0, badMid
		addi $v0, $0, 4
		syscall		
		li $v0, 0
		jr $ra
		
extendString:	#$a0 = address of String, $a1 = length of String
		#Extends the string to work with the hashTable by adding quotes
		lb $t1, quote		
extenLoop:	add $t0, $a0, $a1
		sb $t1, ($t0)
		addi $a1, $a1, 1
		bne $a1, 9 extenLoop
		add $t0, $a0, $a1
		sb $0, ($t0)	#Stores a null to end the string
		jr $ra
		
		
		
