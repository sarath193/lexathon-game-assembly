.text
endGame:	la $a0, endScore
		addi $v0, $0, 4
		syscall			#Print Score
		lw $a0, score
		addi $v0, $0, 1
		syscall
		
		
		la $a0, wordCount
		addi $v0, $0, 4
		syscall			#Print Words Found and percentage
		lw $t0, wordsFound
		add $a0, $t0, $0
		addi $v0, $0, 1
		syscall
		
		j gameStart
