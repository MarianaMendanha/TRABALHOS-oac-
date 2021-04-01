.include "a_branch.asm"
.include "b_branch.asm"
.include "c_branch.asm"
.include "d_branch.asm"
.include "j_branch.asm"
.include "l_branch.asm"
.include "m_branch.asm"
.include "n_branch.asm"
.include "o_branch.asm"
.include "s_branch.asm"
.include "x_branch.asm"

.data
npc_memoria: .space 4
ppc_memoria: .space 8
trespace: .asciiz " : "
n_memoria: .space 4
p_memoria: .space 10
read_file: .asciiz "/home/mariana/Desktop/OAC/example_saida.asm"
write_file_data: .asciiz "/home/mariana/Desktop/OAC/saida_data.mif"
write_file_text: .asciiz "/home/mariana/Desktop/OAC/saida_text.mif"
erro_abertura: .asciiz "Erro de abertura do arquivo"
erro_leitura: .asciiz "Erro de leitura do arquivo"
erro_instrucao: .asciiz "Instrução inválida"
cabecalho_data:  .ascii  "DEPTH = 16384;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n" 
cabecalho_text:	.ascii "DEPTH = 4096;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"
cabecalho_end:	.ascii "\nEND;\n"
space: .space 1024

.text
jal abre_arquivoleitura			# abre arquivo
blt $v0, $zero, error_abertura	# se erro na abertura, executa error_abertura

jal leitura						# lê o arquivo de entrada e armazena
blt $v0, $zero, error_leitura	# se erro na leitura, executa error_leitura

jal fecha_arquivo

la $s0, space					# s0 com endereço do primeiro caracter

loop:	
lb $t0, 0($s0)						# t0 com o char lido 
beq $t0, 0x00, exit				# se o char lido for barra zero, vai pro exit
beq $t0, 0x2E, data_text		# se o char lido for ponto, é data ou text
addi $s0, $s0, 1				# avança o ponteiro
j loop							# loop em read até ler o barra zero

data_text:
jal next_char					# próximo char em $t0
beq $t0, 0x64, data 			# se o próximo char for 'd', .data !
beq $t0, 0x74, text   			# se o próximo char for 't', .text !
j error_instrucao

data:
jal next_char
bne $t0, 0x61, error_instrucao	# se o próximo char não for 'a', erro !
jal next_char
bne $t0, 0x74, error_instrucao	# se o próximo char não for 't', erro !
jal next_char
bne $t0, 0x61, error_instrucao	# se o próximo char não for 'a', erro !

jal open_write_arquivo_data

move $a0, $s7
li $v0, 15 
la $a1, cabecalho_data
li $a2, 81
syscall				# print no arquivo o cabeçalho do data.mif

li $t7, 0x10010000
sw $t7, npc_memoria($zero)

j monta_data

monta_data:
jal procura_barran
jal procura_doispontos
jal verifica_pontoword
jal next_char
beq $t0, 0x2C, error_instrucao	# se o próximo char for ',', erro !
le_num:
move $a0, $s0
jal sa
move $s0, $v0
sw $v1, n_memoria($zero)
jal hex
addi $s0, $s0, -1
verifica_depois:
jal next_char
beq $t0, 0x20, verifica_depois 	# se o próximo char for ' ', verifica mais espaços !
beq $t0, 0x2c, verifica_depois 	# se o próximo char for ',', verifica mais espaços !
beq $t0, 0x00, termina		# se o próximo char for ' \0', fim do arquivo !
bne $t0, 0x0A, le_num		# se o próximo char não for '\n', é número
verifica_mais:
jal next_char
beq $t0, 0x2E, termina		# se o próximo char for '.', termina e vai para o loop inicial
bne $t0, 0x0A, monta_data	# se o próximo char não for '\n', é novo .word
j verifica_mais

text:
jal next_char
bne $t0, 0x65, error_instrucao	# se o próximo char não for 'e', erro !
jal next_char
bne $t0, 0x78, error_instrucao	# se o próximo char não for 'x', erro !
jal next_char
bne $t0, 0x74, error_instrucao	# se o próximo char não for 't', erro !
jal procura_barran
jal open_write_arquivo_text

move $a0, $s7
li $v0, 15 
la $a1, cabecalho_text
li $a2, 80
syscall				# print no arquivo o cabeçalho do text.mif

li $t7, 0x00400000
sw $t7, npc_memoria($zero)

j monta_text

monta_text:
addi $s0, $s0, 1
lb $t0, 0($s0)
beq $t0, 0x61, label_a	# se o primeiro caracter for 'a', procura a instrução em a_branch
beq $t0, 0x62, label_b	# se o primeiro caracter for 'b', procura a instrução em b_branch
beq $t0, 0x63, label_c	# se o primeiro caracter for 'c', procura a instrução em c_branch
beq $t0, 0x64, label_d	# se o primeiro caracter for 'd', procura a instrução em d_branch
beq $t0, 0x6A, label_j	# se o primeiro caracter for 'j', procura a instrução em j_branch
beq $t0, 0x6C, label_l	# se o primeiro caracter for 'l', procura a instrução em l_branch
beq $t0, 0x6D, label_m	# se o primeiro caracter for 'm', procura a instrução em m_branch
beq $t0, 0x6E, label_n	# se o primeiro caracter for 'n', procura a instrução em n_branch
beq $t0, 0x6F, label_o	# se o primeiro caracter for 'o', procura a instrução em o_branch
beq $t0, 0x73, label_s	# se o primeiro caracter for 's', procura a instrução em s_branch
beq $t0, 0x78, label_x	# se o primeiro caracter for 'x', procura a instrução em x_branch
beq $t0, 0x2E, procura_terminar  # se o primeiro caracter for '.', termina e volta para o loop inicial
beq $t0, 0x00, procura_terminar  # se o primeiro caracter for '\0', termina e volta para o loop inicial
bne $t0, 0x0A, error_instrucao # se o primeiro caracter não for '\n', error_instrucao !
j monta_text

procura_terminar:
jal procura_barran
j termina

termina:
move $a0, $s7
li $v0, 15 
la $a1, cabecalho_end
li $a2, 6
syscall	

jal fecha_arquivo
j loop	

procura_barran:
addi $s0, $s0, 1	# pega o próximo char (next_char)
lb $t0, 0($s0)
beq $t0, 0x0A, procura_barran	# se o próximo char for '\n', loop
addi $s0, $s0, -1
jr $ra 				# próximo caracter dentro do .data / .text

procura_doispontos:
addi $s0, $s0, 1		# pega o próximo char (next_char)
lb $t0, 0($s0)
bne $t0, 0x3A, procura_doispontos	# se o próximo char não for ':', loop
jr $ra

verifica_pontoword:
addi $s0, $s0, 2
lb $t0, 0($s0)		# pega o próximo char (next_char)
bne $t0, 0x2E, error_instrucao	# se o próximo char não for '.', erro !
addi $s0, $s0, 1
lb $t0, 0($s0)		# pega o próximo char (next_char)
bne $t0, 0x77, error_instrucao	# se o próximo char não for 'w', erro !
addi $s0, $s0, 1
lb $t0, 0($s0)		# pega o próximo char (next_char)
bne $t0, 0x6F, error_instrucao	# se o próximo char não for 'o', erro !
addi $s0, $s0, 1
lb $t0, 0($s0)		# pega o próximo char (next_char)
bne $t0, 0x72, error_instrucao	# se o próximo char não for 'r', erro !
addi $s0, $s0, 1	
lb $t0, 0($s0)		# pega o próximo char (next_char)
bne $t0, 0x64, error_instrucao	# se o próximo char não for 'd', erro !
addi $s0, $s0, 1
jr $ra

next_char:					# pega o próximo caracter recebido do arquivo
addi $s0, $s0, 1
lb $t0, 0($s0)
jr $ra

error_instrucao:					# instrução inválida
li $v0, 4
la $a0, erro_instrucao
syscall
j exit

abre_arquivoleitura:					# Abre o arquivo de input
li $v0, 13
la $a0, read_file
li $a1, 0
li $a2, 0
syscall
move $s1, $v0
jr $ra

open_write_arquivo_data:
li $v0, 13
la $a0, write_file_data
li $a1, 1
li $a2, 0
syscall
move $s7, $v0
jr $ra

open_write_arquivo_text:
li $v0, 13
la $a0, write_file_text
li $a1, 1
li $a2, 0
syscall
move $s7, $v0
jr $ra

error_abertura:					# Erro ao abrir arquivo
li $v0, 4
la $a0, erro_abertura
syscall
j exit

leitura:						# Ler o arquivo de input
li $v0, 14
move $a0, $s1
la $a1, space
li $a2, 1024
syscall
jr $ra

error_leitura:					# Erro ao ler o arquivo de input
li $v0, 4
la $a0, erro_leitura
syscall
j exit

fecha_arquivo:					# Fecha o arquivo de input
li $v0, 16
move $a0, $s1
syscall
jr $ra

exit:							# Termina o programa
li $v0, 10
syscall

# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

r:
lb $t0, 0($a0)
beq $t0, 0x24, continua_r #0x24é '$'
addi $a0, $a0, 1
lb $t0, 0($a0)
beq $t0, 0x20, r	#0x20 é ' '
bne $t0, 0x24, error_instrucao

continua_r:
sub $sp, $sp, 4 #empilha $ra
sw $ra, 0($sp)	#empilha $ra

addi $a0, $a0, 1
lb $t0, 0($a0)

reg_zero_r:
bne $t0, 0x7A, reg_v_r
jal reg_zero
#sll $v1, $v1, 11, 16 ou 21, dependendo de rd, rt ou rs
j continuareg

reg_v_r:
bne $t0, ,0x76, reg_a_r 
jal reg_v
##sll $v1, $v1, 11
j continuareg

reg_a_r:
bne $t0, 0x61, reg_t_r
jal reg_a
##sll $v1, $v1, 11
j continuareg

reg_t_r:
bne $t0, 0x74, reg_s_r
jal reg_t
##sll $v1, $v1, 11
j continuareg

reg_s_r:
bne $t0, 0x73, reg_k_r
jal reg_s
##sll $v1, $v1, 11
j continuareg

reg_k_r:
bne $t0, 0x6B, reg_outros_r
jal reg_k
##sll $v1, $v1, 11
j continuareg

reg_outros_r:
jal reg_outros
##sll $v1, $v1, 11
j continuareg


target:

offset:

reg_zero:
addi $a0, $a0, 1
lb $t0, 0($a0)
bne $t0, 0x65, error_instrucao
addi $a0, $a0, 1
lb $t0, 0($a0)
bne $t0, 0x72, error_instrucao
addi $a0, $a0, 1
lb $t0, 0($a0)
bne $t0, 0x6F, error_instrucao
addu $v1, $zero, $zero #no caso, é $zero

jr $ra

reg_v:
addi $a0, $a0, 1
lb $t0, 0($a0)
#Supomos que está certo, okay??
continua_reg_v:
addiu $v1, $zero, 2 #no caso, é $vX
addu $v1, $v1, $t0
subiu $v1, $v1, 48

jr $ra

reg_a:
addi $a0, $a0, 1
lb $t0, 0($a0)
#Supomos que está certo, okay??
bne $t0, 0x74, naoeh_at
addiu $v1, $zero, 1
jr $ra
naoeh_at:
addiu $v1, $zero, 4
addu $v1, $v1, $t0
subiu $v1, $v1, 48

jr $ra

reg_t:
addi $a0, $a0, 1
lb $t0, 0($a0)
#Supomos que está certo, okay??
beq $t0, 0x38, eh8ou9 #é $t8, no caso
beq $t0, 0x39, eh8ou9
addiu $v1, $zero, 8
addu $v1, $v1, $t0
subiu $v1, $v1, 48
jr $ra
eh8ou9:
addiu $v1, $zero, 16
addu $v1, $v1, $t0
subiu $v1, $v1, 48
jr $ra

reg_s:
addi $a0, $a0, 1
lb $t0, 0($a0)
#Supomos que está certo, okay??
bne $t0, 0x70, naoeh_sp
addiu $v1, $zero, 29
jr $ra
naoeh_sp:
addiu $v1, $zero, 16
addu $v1, $v1, $t0
subiu $v1, $v1, 48
jr $ra

reg_k:
addiu $v1, $zero, 26 #no caso, é $kX
addu $v1, $v1, $t0
subiu $v1, $v1, 48

jr $ra

reg_outros:
addiu $a0, $a0, 1 
beq $t0, 0x66, ehF
beq $t0, 0x71, ehR
bne $t0, 0x67, error_instrucao
addiu $v1, $zero, 28
jr $ra
ehF:
addiu $v1, $zero, 30
jr $ra
ehR:
addiu $v1, $zero, 31
jr $ra

continuareg:
lw $ra, 0($sp) 
addiu $sp, $sp, 4

addiu $a0, $a0, 1
move $v0, $a0
jr $ra

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

sa: #já começa no char do número, e não no negativo ou espaço
li $t4, 0
lb $t0, 0($a0)
bne $t0, 48, sa_1	#verifica se é 0 o primeiro dígito
lb $t0, 1($a0)	# uma vez sendo 0, vê se é 'x' ou 'X' o próximo (representação em hexadecimal), se não, segue normalmente

bne $t0, 0x78, qual_hexa
bne $t0, 0x58 ,qual_hexa

sa_1:
lb $t0, 0($a0) #lê o char
bgt $t0, 0x39, error_instrucao	#se for maior que '9', já está errado!
bge $t0, 0x30, continua_sa	#se for entre '0' e '9', é número
testa_final_numero:
seq $t1, $t0, 0x2C	#se for ' ', ',', '\n', ou '\0' é porque acabou o número
seq $t2, $t0, 0x0A	# ..
or $t1, $t1, $t2	# ..
seq $t2, $t0, 0x20	# .. 
or $t1, $t1, $t2	#verifica se é igual a algum dos citados acima
seq $t2, $t0, 0	#..
or $t1, $t1, $t2	#..
seq $t2, $t0, 0x28
or $t1, $t1, $t2
beqz $t1, error_instrucao	# se der 0, é pq não é igual a nenhum dos citados acima, e então, é erro!
or $v1, $t4, $zero	#se chegou então até aqui, é porqque já calculou o número e pode voltar pra main
move $v0, $a0
jr $ra 
continua_sa:	#lê o número
#multiplicar por 10 é multiplicar por 8 e somar duas vezes a cada vez que lê um número novo, começando do 0
move $t5, $t4
sll $t4, $t4, 3
addu $t4, $t5, $t4
addu $t4, $t5, $t4
# fim multiplicação por 10
subiu $t0, $t0, 48	 
addu $t4, $t4, $t0	#soma o próprio número no resultado final
addiu $a0, $a0, 1
j sa_1

qual_hexa:
addiu $a0, $a0, 2
continua_qual_hexa:

lb $t0, 0($a0)
bgt $t0, 0x66, error_instrucao
bge $t0, 0x61, minuscula_hex
bgt $t0, 0x46, error_instrucao
bge $t0, 0x41, maiuscula_hex
bgt $t0, 0x39, error_instrucao
bge $t0, 0x30, numero_hex

j testa_final_numero

minuscula_hex:
sll $t4, $t4, 4
subiu $t0, $t0, 87
addu $t4, $t4, $t0
addiu $a0, $a0, 1
j continua_qual_hexa

maiuscula_hex:
sll $t4, $t4, 4
subiu $t0, $t0, 55
addu $t4, $t4, $t0
addiu $a0, $a0, 1
j continua_qual_hexa

numero_hex:
sll $t4, $t4, 4
subiu $t0, $t0, 48
addu $t4, $t4, $t0
addiu $a0, $a0, 1
j continua_qual_hexa

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

hex:	# função transforma em hexadecimal ascii o que tem em n_memoria, armazenando a "string" em p_memoria
li $t0, 0	# incrementador de p_memoria
li $t3, 3	# lê de trás pra frente o bytes de n_memoria
li $t4, 0x3B	# coloca, ';' em $t4
li $t5, 0x0A	# coloca, '\n' em $t5

loop_hex3:	# começa a ler os bytes, de trás pra frente, do número armazenado em n_memoria
lb $t1, npc_memoria($t3)	# carrega em $t1 o byte mais significativo de n_memoria
andi $t2, $t1, 0x0F	# isola os 4 bits menos significativos, e transforma o número ao charactere corrempondente em ascii
blt $t2, 10, loop_hex4	
addiu $t2, $t2, 39
loop_hex4:
addiu $t2, $t2, 48
srl $t1, $t1, 4	# isola agora os 4 bits mais significativos, e transforma em ascii
blt $t1, 10, loop_hex5
addiu $t1, $t1, 39
loop_hex5:
addiu $t1, $t1, 48
sb $t1, ppc_memoria($t0) #armazena a letra dos 4 bits mais significativos primeiro na string
addiu $t0, $t0, 1
sb $t2, ppc_memoria($t0) #armazena a letra dos 4 bits menos significativos na string
addiu $t0, $t0, 1
addiu $t3, $t3, -1
bne $t0, 8, loop_hex3	#se nao tiver lido os 8 bytes (10 - 2), continua o loo

li $t0, 0	# incrementador de p_memoria
li $t3, 3	# lê de trás pra frente os bytes de n_memoria

loop_hex:	# começa a ler os bytes, de trás pra frente, do número armazenado em n_memoria
lb $t1, n_memoria($t3)	# carrega em $t1 o byte mais significativo de n_memoria
andi $t2, $t1, 0x0F	# isola os 4 bits menos significativos, e transforma o número ao charactere corrempondente em ascii
blt $t2, 10, loop_hex1	
addiu $t2, $t2, 39
loop_hex1:
addiu $t2, $t2, 48
srl $t1, $t1, 4	# isola agora os 4 bits mais significativos, e transforma em ascii
andi $t1, $t1, 0x0F
blt $t1, 10, loop_hex2
addiu $t1, $t1, 39
loop_hex2:
addiu $t1, $t1, 48
sb $t1, p_memoria($t0) #armazena a letra dos 4 bits mais significativos primeiro na string
addiu $t0, $t0, 1
sb $t2, p_memoria($t0)	#armazena a letra dos 4 bits menos significativos na string
addiu $t0, $t0, 1
addiu $t3, $t3, -1
bne $t0, 8, loop_hex	#se nao tiver lido os 8 bytes (10 - 2), continua o loop
sb $t4, p_memoria($t0)
addiu $t0, $t0, 1
sb $t5, p_memoria($t0)

move $a0, $s7
li $v0, 15 
la $a1, ppc_memoria
li $a2, 11
syscall

move $a0, $s7
li $v0, 15 
la $a1, p_memoria
li $a2, 10
syscall

lw $t7, npc_memoria($zero)
addiu $t7, $t7, 4
sw $t7, npc_memoria($zero)

jr $ra

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

label_a:
a_branch

label_b:
b_branch

label_c:
c_branch

label_d:
d_branch

label_j:
j_branch

label_l:
l_branch

label_m:
m_branch

label_n:
n_branch

label_o:
o_branch

label_s:
s_branch

label_x:
x_branch
