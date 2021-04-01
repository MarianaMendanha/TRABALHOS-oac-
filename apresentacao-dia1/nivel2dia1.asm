.data
a: .word 11, 22, 33

.text
li $t0, 0x10010000
lw $t1, 0($t0)
lw $t2, 4($t0)
lw $t3, 8($t0)
add $t1, $t2, $t3
mult $t2, $t3
div $t2, $t3
sra $t1, $t2, 10
sub $t3, $t1, $t2
slt $t4, $t1, $t3
jal salto
sw $t1, 0($t0)
sw $t2, 4($t0)
sw $t4, 8($t0)
salto: sw $t1, 0($t0)
sw $t2, 4($t0)
sw $t3, 8($t0)
