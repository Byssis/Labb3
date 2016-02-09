.global makelist

.macro PUSH (%reg)
	addi $sp,$sp,-4
	sw %reg,0($sp)
.end_macro

.macro POP (%reg)
	lw %reg,0($sp)
	addi $sp,$sp,4
.end_macro

.data
.align 2

factlist: .space 32 			# facklist why 32?

.text

start:
	jal main
	nop
stop:   j stop

fact:
	addi $v0, $zero, 1		# r = 1
while:
	ble $a0, $zero, done		# n <= 0
	mul $v0, $v0, $a0		# r = r*n	
	addi $t0, $t0, -1		# n--
	j while
	nop 	
done:	
	jr $ra
	nop
	
makelist:
	PUSH ($ra)
	PUSH ($s0)			# start
	PUSH ($s1) 			# length
	PUSH ($s2)			# i
	PUSH ($s3)			# address
	
	add $s0, $0, $0 		# i = 0
	add $s1, $a0, $zero
	add $s2, $a1, $zero
	la $s3, factlist	
makeloop:
	slt $t0, $s2,$s1 		# i < length
	beq $t0, $0, endmake
	
	move $s0, $a0			# move $s0 to $a0
	
	jal fact
	nop
	
	sw $s3, 0($s3)
	addi	$s0, $s0, 1
	addi $s3, $s3, 4
	addi	$s2, $s2, 1
	j makeloop
endmake:
	POP ($s3)
	POP ($s2)
	POP ($s1) 
	POP ($s0)
	POP ($ra)
	jr $ra
	
# Main function
main: 
	PUSH ($ra)
	addi $a0,$0,3
	addi $a1,$0,8
	jal makelist
	POP ($ra)
	jr $ra
	