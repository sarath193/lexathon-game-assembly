.text

instDialog:
	la 	$a0, inst1
	li 	$v0, 4
	syscall
	
	la 	$a0, inst2
	syscall
	la 	$a0, inst3
	syscall
	la 	$a0, inst4
	syscall
	la 	$a0, inst5
	syscall
	la 	$a0, inst6
	syscall
	la 	$a0, inst7
	syscall
	la 	$a0, inst8
	syscall
	la 	$a0, inst9
	syscall

	
	jr $ra
	
