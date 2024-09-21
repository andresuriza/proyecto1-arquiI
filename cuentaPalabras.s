.data
	palabra: .zero 50
	file: .asciz "preprocess.txt"
	postpros: .string "postprocess.bin"
	count: .word 0
	str1: .zero 2000000	

.text
.global _start
_start:
	mov r7, #5	// abre archivo
	ldr r0, =file
	mov r1, #0
	mov r2, #0777
	swi 0
	
	mov r7, #3	// lee
	ldr r1, =str1
	ldr r2, =#2000000	// size 2mb
	swi 0
	
	mov r7, #6
	mov r0, r7
	swi 0
	
	mov r1, #0
	ldr r1, =str1
	ldr r3, =palabra
	mov r2, #0 // buffer texto
	mov r4, #0 // cantidad de repeticiones
	mov r5, #0 // buffer palabras
	mov r6, #0 // tamano letra
	
buscaWord:
	ldrb r2, [r1]
	add r1, r1, #1
	cmp r2, #0x2e
	beq exit 
	cmp r2, #0xa
	beq compare1
	strb r2, [r3]
	add r6, r6, #1 // offset texto
	add r8, r8, #1 // tamano palabra
	add r3, r3, #1
	b buscaWord

compare1:
	add r4, r4, #1	// Ocurrencias de palabra
	ldr r3, =palabra
	cmp r2, #0	// Si se termina recorrer texto
	beq prepWrite

compare2:
	ldrb r2, [r1]	// Carga siguiente caracter
	add r1, r1, #1
	ldrb r5, [r3]	// Carga caracter
	add r3, r3, #1
	cmp r5, #0	// Si se termina recorrer palabra
	beq compare3
	cmp r2, r5
	beq compare2 // Si son iguales
	
nextWord:
	ldr r3, =palabra
	cmp r2, #0x2e	// Si se termina recorrer texto
	beq prepWrite
	cmp r2, #0xa
	beq compare2
	ldrb r2, [r1]
	add r1, r1, #1
	b nextWord
	
compare3:
	cmp r2, #0xa // Si palabras coinciden
	beq compare1 
	cmp r2, #0x2e	// Si se termina recorrer texto
	beq compare1
	ldr r3, =palabra
	b compare2

prepWrite:
	add r3, r3, r8

	mov r2, #0xd
	strb r2, [r3]

	add r3, r3, #1
	mov r2, #0xa
	strb r2, [r3]

	mov r7, #5
	ldr r0, =postpros
	mov r1, #0x441	// O_CREAT, O_WRONLY, O_APPEND
	mov r2, #0666	// read-write
	swi 0

	mov r7, #4 // Escribe
	add r8, r8, #2
	mov r2, r8
	ldr r1, =palabra
	swi 0

	sub r8, r8, #2 // Regresa a tamano +1

	mov r7, #6 // Cierra archivo
	mov r0, r7
	swi 0

	mov r7, #5
	ldr r0, =postpros
	mov r1, #0x441	// O_CREAT, O_WRONLY, O_APPEND
	mov r2, #0666	// read-write
	swi 0

	mov r2, r4
	ldr r1, =count
	strb r2, [r1]

	add r1, r1, #1
	mov r2, #0xd
	strb r2, [r1]

	add r1, r1, #1
	mov r2, #0xa
	strb r2, [r1]

	mov r7, #4 // Escribe
	mov r2, #3
	ldr r1, =count
	swi 0

	mov r7, #6 // Cierra archivo
	mov r0, r7
	swi 0

cleanWord:
	ldr r3, =palabra
	ldr r1, =str1
	add r6, r6, #1 // Para ignorar /n?
	add r1, r1, r6 // Offset a siguiente palabra
	mov r8, #50

cleanWord2:	
	sub r8, r8, #1
	mov r7, #0
	strb r7, [r3]
	add r3, r3, #1
	cmp r8, #0
	bne cleanWord2
	ldr r3, =palabra

resetPtr:
	mov r2, #0 // buffer texto
	mov r4, #0 // cantidad de repeticiones
	mov r5, #0 // buffer palabras
	mov r8, #0 // tamano letra
	b buscaWord 

exit:
	mov r7, #6 // Cierra archivo
	mov r0, r7
	swi 0
	
	mov r7, #1
	swi 0
