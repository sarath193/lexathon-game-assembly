.eqv TABLE_SIZE 4096
.eqv NUM_WORDS 74563
.eqv NUM_WORDS_PLUS_ONE 74564

.data

# This program makes the hashtable from the word list .txt file
#Loading_Message: .asciiz "Constructing hashtable! This may take some time!\nYou may want to just run Lexathon normally after looking at this code.\n\n"
dictionaryFile: .asciiz "Dictionary.txt"
hashTableFile: .asciiz "hashTable.dat"

#Here we allocate memory for Userunput (only used when testing), and tempWords
.align 2
userInputBuffer: .space 10
.align 2
tempWord: .space 4

top:	.asciiz "\n-------------\n"
middle:	.asciiz "|-----------|\n"
bottom:	.asciiz "-------------\n"
left:	.asciiz "| "
right:	.asciiz " |\n"
inside:	.asciiz " | "


inst1:	.asciiz "\n\n################### GAME INSTRUCTIONS ########################\n\n"
inst2:	.asciiz "\nThe insts for the game are as follows:\n\n"
inst3:	.asciiz "1) Words should have atleast 4 letters but not more than 9 letters.\n"
inst4:	.asciiz "2) The middle letter must be included in the words formed.\n"
inst5:	.asciiz "3) Player has 60 seconds to enter the  word.\n"
inst6:	.asciiz "4) Each correct word entered will add 20 seconds on the clock.\n"
inst7:	.asciiz "5) Only words found in dictionary can be counted.\n"
inst8:	.asciiz "6) Dulpicate entires will not be counted .\n\n"
inst9:	.asciiz "That's all! Have fun playing!\n\n"

	
startPrompt:	.asciiz	"\n\nStart New Game? (Y/N)\n"
MenuIntro: .asciiz "Welcome to the Lexathon MIPS Game!\n"
MenuButtons: .asciiz "Press 1 - If you like to Start New Game\nPress 2 - To get the instructions of the Game\nPress 3 - Your Scores\nPress 0 -Would you like to Quit the Game\n"
MenuSelection: .asciiz "Enter menu selection: "
ExitGame: .asciiz "Exit Game: Press 0"
askIn:		.asciiz	"\nInput: "
timeRem:	.asciiz	"\nTime Remaining: "
endScore:	.asciiz	"\nScore: "
wordCount:	.asciiz	"\nWords Found: "
slash:		.asciiz	"/"
newLine:	.asciiz	"\n"
wPercent:	.asciiz"\nWord Percentage: "
percent:	.asciiz	"%"
badLength:	.asciiz"\nWord MUST be between 4 and 9"
badChar:	.asciiz"\nInvalid word. Try again."
badMid:		.asciiz"\nWord MUST contain the middle letter."
badDict:	.asciiz"\nWord not found in dictionary. Try again."
wordUsed:	.asciiz"\nWord already used"
charFile:	.asciiz "ninechar.txt"
quote:		.asciiz "`"	

startTime:	.word 0
endTime:	.word 60
score:		.word 0
wordsFound:	.word 0

wordSpace:	.space 9		#Used to store the full string
char1:		.byte 'a'
char2:		.byte 'a'
char3:		.byte 'a'
char4:		.byte 'a'		#These are used to store each character
char5:		.byte 'a'
char6:		.byte 'a'
char7:		.byte 'a'
char8:		.byte 'a'
charmid:	.byte 'a'
charUsed:	.space 9		#Used to check if each character is used

charList:	.space 150228		#For the ninechar.txt
		.word
userIn:		.space 4096
		.word
foundList:	.space 1024		#To put the list of words found.

TableSize: .word 0
numWordsInHashtable: .word 0
addressFirstElement: .word 0		

	
	####TEST INPUTS#### 
	#Type in 1 to shuffle the letters
	#Enter nothing to just repeat the input prompt
	#Enter text and the program will score it. Does not check if in dictionary yet
	#Enter 0 to quit
	
	.text
hashOpen:
	la $a0, hashTableFile
	jal OpenHashTable	
	

menu:
	# Display intro text for game
	li $v0, 4
	la $a0, MenuIntro
	syscall

	# Display available menu buttons
	li $v0, 4
	la $a0, MenuButtons
	syscall

	# Prompt for menu selection
	li $v0, 4
	la $a0, MenuSelection
	syscall

	# Read menu selection
	li $v0, 5
	syscall								
	
	# If user entered 1, Go to setup to start game
	beq $v0, 1, setup
	
	# If user entered 0, Exit Game
	beqz $v0, exit 
	
	beq $v0, 2, instDialog
	
gameStart:	

	la $a0, startPrompt
	addi $v0, $0, 4
	syscall			#Ask to start game
	la $a0, userIn
	la $a1, userIn
	addi $v0, $0, 8
	syscall			#Get user input
	
	lb $t0, userIn		#Puts the input into t0
	beq $t0, 'Y', setup
	beq $t0, 'N', exit
	beq $t0, 'y', setup
	beq $t0, 'n', exit
	
	j gameStart		#Incase the input is not yes or no
	
setup:		#Put all stuff that ust be done before each game here
		#Plan: Get start time at the end of the setup
		#Also generate the letters used and reset any variables or words or memory if necessary
		
		
		sw $0 score
		sw $0 wordsFound	
		#sw $0 wordsTotal	#Put stuff used to find total number of words here
		
		addi $v0, $0, 13      	#Open file
		la $a0, charFile      
		addi $a1, $0, 0       
		addi $a2, $0, 0
		syscall            
		addi $t0, $v0, 0    	#Save the file descriptor 
		
		addi $a0, $t0, 0
		la $a1, charList
		addi $a2, $0, 150228		#Number of characters to read
		addi $v0, $0, 14
		syscall
		
		addi   $v0, $0, 16      #Close file
		addi $a0, $t0, 0      	
		syscall            # close file
		
		la $a0, charList
		jal getWord
		
		jal setMidChar
		
		
		addi $t0, $0, 60
		sw $t0, endTime		#Sets the time limit to 60 seconds
		
		jal getTime	#Get starting time
		sw $v0, startTime
			
		jal shuffleChars	#Shuffles letters and starts the game
		
	
main:
		la $a0, newLine	#New Line	
		addi $v0, $0, 4
		syscall
		
		la 	$a0, top
	  	li 	$v0, 4
		syscall
		
		la 	$a0, left
	 	li 	$v0, 4
	  	syscall
		
		li $v0, 11
		lb $a0, char1
		syscall
		
		la 	$a0, inside
		li 	$v0, 4
		syscall
		
		li $v0, 11
		lb $a0, char2
		syscall
		
		la 	$a0, inside
		li 	$v0, 4
		syscall
		
		li $v0, 11
		lb $a0, char3
		syscall
		
		la 	$a0, right
		li 	$v0, 4
		syscall
		
		la 	$a0, middle
		li 	$v0, 4
		syscall
		
		la 	$a0, left
	 	li 	$v0, 4
	  	syscall
		
		li $v0, 11
		lb $a0, char4
		syscall
		
		la 	$a0, inside
		li 	$v0, 4
		syscall
		
		li $v0, 11
		lb $a0, charmid
		syscall
		
		la 	$a0, inside
		li 	$v0, 4
		syscall
		
		li $v0, 11
		lb $a0, char5		#This stuff just disorderly prints the list of characters. The "mid" char is on the new line
		syscall
		
		la 	$a0, right
		li 	$v0, 4
		syscall
		
		la 	$a0, middle
		li 	$v0, 4
		syscall
		
		la 	$a0, left
	 	li 	$v0, 4
	  	syscall
		
		li $v0, 11
		lb $a0, char6
		syscall
		
		la 	$a0, inside
		li 	$v0, 4
		syscall
		
		li $v0, 11
		lb $a0, char7
		syscall
		
		la 	$a0, inside
		li 	$v0, 4
		syscall
		
		li $v0, 11
		lb $a0, char8
		syscall
		
		la 	$a0, right
		li 	$v0, 4
		syscall
		
		la 	$a0, bottom
		li 	$v0, 4
		syscall
		

		
		lw $a0, startTime	
		jal calcTime
		
		lw $t0, endTime
		add $s7, $v0, $t0
		blt $s7, $0, endGame
		
		la $a0, timeRem		#Prints the time remaining text
		addi $v0, $0, 4
		syscall
		add $a0, $s7, $0
		addi $v0, $0, 1
		syscall			#Prints the time remaining
		
		la $a0, endScore	#Prints the score text (this text is also used at the end, hence the name)
		addi $v0, $0, 4
		syscall
		lw $a0, score
		addi $v0, $0, 1
		syscall			#Prints the score

		la $a0, askIn
		addi $v0, $0, 4
		syscall			#Asks for user input
		la $a0, userIn
		la $a1, userIn
		addi $v0, $0, 8
		syscall			#Get user input
		
		la $a0, newLine	#New Line	
		addi $v0, $0, 4
		syscall
		la $a0, newLine	#New Line	
		addi $v0, $0, 4
		syscall
		
		lw $a0, startTime	
		jal calcTime
		
		lw $t0, endTime		#Does a time check just in case the user was too slow entering a word
		add $s7, $v0, $t0
		blt $s7, $0, endGame
		#Add checks for various functions here as well as for typing in words
		lb $t0, userIn
		beq $t0, '1', shuffleChars
		beq $t0, '0', endGame
		beq $t0, 0, next
		
		la $a0, userIn
		
		jal usesChars
		
		beqz $v0, next

		la $a0, userIn
		#Add a check here to see if the word has been found before. 
		
		la $t0, userIn
		li $v0, -1
		jal stringLength
		move $a1, $v0		#Gets the length for the extend string function
		jal extendString	#Extends string to work with hashTable
		la $a0, userIn
		addi $v0, $0, 4
		syscall
		jal ContainedInHashTable
		
		bnez $v0, notInDict
		
		la $a0, userIn
		jal checkUsed
		
		bne $v0, 1, usedAlready	#If the word has been used already, it will branch to display a message and not give score
		jal correctWord	
		
next:		j main			#Loopylooploop

notInDict:	la $a0, badDict
		addi $v0, $0, 4
		syscall		
		li $v0, 0
		j main
		
		
usedAlready:	la $a0, wordUsed
		addi $v0, $0, 4
		syscall		
		li $v0, 0
		j main


	.include "hashtable_words.asm"
	.include "Functs.asm"
	.include "endOfGame.asm"
	.include "getGrid.asm"
	.include "validateWord.asm"
	.include "instDialog.asm"

exit:	
	# Exit Game
	li $v0, 10
	syscall
