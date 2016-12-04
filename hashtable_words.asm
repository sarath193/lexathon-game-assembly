
.text
OpenHashTable:
###
# Puts the hashtable in memory.
# Uses hashtable_builder

# Use this with pointer to file as argument in the beginning of Lexathon
# Note that this uses every register

###
li $v0, 13
li $a1, 0 	#read file
li $a2, 0 	
syscall
move $t0, $v0	#file reference in v0

la $a1, addressFirstElement	#Read file
move $a0, $t0	
li $a2, 4
li $v0, 14
syscall

la $a1, numWordsInHashtable
li $v0, 14
syscall

la $a1, TableSize
li $v0, 14
syscall

li $t1, 18
lw $t2, numWordsInHashtable
mul $a2, $t1, $t2
lw $t1, TableSize
add $a2, $a2, $t1

move $a0, $a2
li $v0, 9 
syscall
move $s0, $v0

move $t3, $a2

move $a0, $t0
move $a1, $s0
move $a2, $t3
li $v0, 14
syscall

lw $a0, addressFirstElement
subu $t0, $s0, $a0
beqz $t0, OHQuit

#t0 difference
#t2 is for incrementing through loop
#t3 loopcounter


lw $t2, numWordsInHashtable
sll $t2, $t2, 3
lw $t1, TableSize
add $t1, $t1, $t2

srl $t1, $t1, 2


li $t3, 0
move $t2, $s0
OHCorrectAddressesLoop:
lw $t4, ($t2)
beqz $t4, OHWordDone

add $t4, $t4, $t0


sw $t4, ($t2)
OHWordDone:
addi $t2, $t2, 4
addi $t3, $t3, 1
beq $t1, $t3, OHQuit
b OHCorrectAddressesLoop
OHQuit:
jr $ra


ContainedInHashTable:
###
#This method determines if the word is in hashtable, returns 0 if yes, 1 if no
###
move $t7, $ra
jal HashFunction
move $ra, $t7
sll $v0, $v0, 2
add $v0, $v0, $s0	
lw $t0, ($v0)
beqz $t0, ContainFail 
ContainLoop:
lw $a1, ($t0)
move $t7, $ra
move $t6, $t0
jal WordCmp
move $t0, $t6
move $ra, $t7
beqz $v0, ContainSuccess
lw $t1, 4($t0)
beqz $t1, ContainFail
move $t0, $t1
b ContainLoop
ContainSuccess:
li $v0, 0
jr $ra
ContainFail:
li $v0, 1
jr $ra


HashFunction:
###
# This makes a value for each string
# between 0 and 1023.

# Have a0 be a 9char string

###
li $v0, 0
li $t2, 0
li $t3, 9
move $t0, $a0
HFloop:
addi $t2, $t2, 1
lb $t1, ($t0)
subi $t3, $t3, 1
beqz $t3, HFquit
subu $t1, $t1, 96 #converts ASCII char to 0 = '`'
mulu $t1, $t1, $t2
addu $v0, $v0, $t1
addi $t0, $t0, 1
j HFloop
HFquit:
li $t2, 1024
divu $v0, $t2
mfhi $v0
jr $ra 


WordCmp:
###
# WordCmp: compares two 9 char strings.
# a0 and a1 must be 2 words or 9char strings

#Returns 0 when successful, 1 when fail
###
li $t4, 9
li $v0, 1
move $t0, $a0
move $t1, $a1
WCLoop:
lb $t2, ($t0)
lb $t3, ($t1)
bne $t2, $t3, WCLoopQuit
subi $t4, $t4, 1
beqz $t4, WCLoopQuitSuccess
addi $t0, $t0, 1
addi $t1, $t1, 1
b WCLoop
WCLoopQuitSuccess:
li $v0, 0
WCLoopQuit:
jr $ra
