	.text
getTime:	addi $a0, $0, 0
		addi $v0, $0, 30
		syscall			#Gets the current system time in milliseconds
		
		addi $t0, $0, 1000
		div $a0, $t0		#Divide the time by 1000 to get seconds
		
		mflo $v0		#Puts the current time in seconds in the return value
		
		jr $ra
		
calcTime:	addi $sp, $sp, -8
		sw $a0, 4($sp)		#Make sure that the argument is the starting time. AKA when the current game began
		sw $ra, 0($sp)
		
		jal getTime
		
		lw $a0, 4($sp)		#$a0 gets changed while doing getTime so it needs to be loaded to be used for the sub
		sub $v0, $a0, $v0	#Subtract the current time and the starting time to get the amount of time that has passed

		lw $ra, 0($sp)
		addi $sp, $sp, 8
		jr $ra
		
addTime:	lw $a0, endTime
		add $v0, $a0, 20	#Adds 20 seconds to the time limit
		sw $v0, endTime
		j main #Make sure this is changed to whatever the main area is


