.eqv TABLE_SIZE 4096
.eqv NUM_WORDS 74563
.eqv NUM_WORDS_PLUS_ONE 74564

.data

# This program makes the hashtable from the word list .txt file
Loading_Message: .asciiz "Constructing hashtable!\n\n"
dictionaryFile: .asciiz "words.txt"
hashTableFile: .asciiz "wordshashtable.dat"

#Here we allocate memory for Userinput and tempWords

.align 2
userInputBuffer: .space 10
.align 2
tempWord: .space 4
addressFirstElement:
TableSize:
numWordsInHashtable:
.text


li $a1, 18	#18 provides memory for pointer table and words
li $a0, NUM_WORDS
mul $a0, $a0, $a1
addiu $a0, $a0, TABLE_SIZE
move $s0, $a0


###
#Put Dictionary onto heap!
#We make a pointer to words
###
li $v0, 13
la $a0, dictionaryFile
li $a1, 0 	#read words file
li $a2, 0 	#open mode - ignored
syscall
move $t0, $v0	#t0 now has the reference to read from the words.txt later on


move $a0, $s0 # the total number of bytes is inserted to $a0
li $v0, 9 #sbrk for dynamic memory allocation, allocates the amount of bytes in a0
syscall

#Now that we've allocated memory for the hashtable its time for offsets!

move $s0, $v0 #s0 now contains address of allocated memory
addi $s1, $s0, TABLE_SIZE # $s1 now contains address of table entries collection
li $a0, NUM_WORDS
li $a1, 8
mul $a0, $a0, $a1
add $s2, $s1, $a0 #s2 now contains address of word collection

li $a0, NUM_WORDS
li $t1, 10
mul $t1, $t1, $a0

move $a1, $s2	#Read from from
move $a0, $t0	#(file reference within $t0)
move $a2, $t1	#(size in bytes of word collection is in $t1)
li $v0, 14
syscall

move $a0, $t0
li $v0, 16 #close file
syscall


#####
#Basically, the hashtable created will have an array of linked lists! 
#####
BuildHashTable:
 
subi $s1, $s1, 8 	

la $a0, Loading_Message		#UI load message
li $v0, 4
syscall

li $t4, 0		#t4 counter used for making a load bar
move $t5, $s2		#t5 points to a certain position in word collection

#Reading words then putting thme in hash table
wordReadLoop:
addi $t4, $t4, 1
move $a0, $t5 		#a0 is pointer to a word to be processed
addiu $t5, $t5, 10 	
beq $t4, NUM_WORDS_PLUS_ONE, SRLDone 

jal HashFunction		#Hash the word in $a0. 
			#The hash value is stored in $v0.

li $t7, 1000 		#Printing progress bar
div $t4, $t7		
move $t7, $v0		
move $t6, $a0		
mfhi $v0
bnez $v0, SRLDontPrintAnything
li $a0, '-'
li $v0, 11
syscall
SRLDontPrintAnything:
move $a0, $t6
move $v0, $t7		#ITS DONE

addiu $s1, $s1, 8	#Move to the next table entry in the collection.
move $t2, $s1

#$t2 contains the address of the 8-byte structure that will hold the address of the word and the address
#of the next link in the chain.
#a0 contains a pointer to the word we are adding, and $v0 contains the
#hash of that word.

sw $a0, ($t2)
sll $v0, $v0, 2
move $v1, $s0
addu $v0, $v0, $v1
lw $t0, ($v0)
bnez $t0, SRLBucketOccupied

sw $t2, ($v0)
b wordReadLoop


SRLBucketOccupied: 	#Entry already at pointerTable($v0)
lw $t1, 4($t0) 		#Check the address field of the entry in the hash table
bnez $t1, SRLBOMoveDownChain
sw $t2, 4($t0) 		
b wordReadLoop 	
SRLBOMoveDownChain:
move $t0, $t1 		
b SRLBucketOccupied 	

SRLDone:
li $a0, '\n'
li $v0, 11
syscall

#hashtable created

li $v0, 13
la $a0, hashTableFile
li $a1, 1 	#write-only to file
li $a2, 0 	
syscall
move $t0, $v0	

#The first 4 bytes of wordshashtable.dat are the address of the hashtable.

sw $s0, tempWord
move $a0, $t0
la $a1, tempWord
li $a2, 4
li $v0, 15
syscall

#The next 8 bytes are:
#	1. Number of words in the hashtable (4 bytes)
#	2. Size of pointer table (4 bytes)

move $a0, $t0
li $a1, NUM_WORDS
sw $a1, tempWord
la $a1, tempWord
li $a2, 4
li $v0, 15
syscall

move $a0, $t0
li $a1, TABLE_SIZE
sw $a1, tempWord
la $a1, tempWord
li $a2, 4
li $v0, 15
syscall

#Finally, the hash table is dumped into the file.

move $a0, $t0
li $a2, NUM_WORDS
li $a1, 18
mul $a2, $a2, $a1
addiu $a2, $a2, TABLE_SIZE
move $a1, $s0
li $v0, 15
syscall

#And then the file is closed.
move $a0, $t0
li $v0, 16
syscall


quitProgram:
li $v0, 10
syscall

.include "words_hashtable.asm"
