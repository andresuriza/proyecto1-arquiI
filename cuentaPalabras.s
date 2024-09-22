.data
	palabra: .zero 50
	file: .asciz "preprocess.txt"
	postpros: .string "postprocess.bin"
	count: .word 0
	str1: .zero 2000000	

.text
.global _start
_start:
	mov r7, #5	// Abre archivo
	ldr r0, =file
	mov r1, #0
	mov r2, #0777
	swi 0
	
	mov r7, #3	// lee
	ldr r1, =str1
	ldr r2, =#2000000	// Tamano 2mb
	swi 0
	
	mov r7, #6 // Cierra archivo
	mov r0, r7
	swi 0
	
	mov r1, #0 // Direccion de memoria texto
	ldr r1, =str1
	ldr r3, =palabra
	mov r2, #0 // Registro para cargar palabra de texto
	mov r4, #0 // cantidad de repeticiones
	mov r5, #0 // Palabra a comparar
	mov r6, #0 // Offset texto
	
buscaWord:
	ldrb r2, [r1]	// Se carga caracter
	add r1, r1, #1
	cmp r2, #0x2e // Si es .
	beq exit 
	cmp r2, #0xa	// Si termina palabra
	beq compare1
	strb r2, [r3]	// Se guarda caracter
	add r6, r6, #1 // Offset texto
	add r8, r8, #1 // Tamano palabra
	add r3, r3, #1
	b buscaWord

compare1:
	add r4, r4, #1	// Ocurrencias de palabra
	ldr r3, =palabra
	cmp r2, #0	// Si se termina recorrer texto
	beq prepWrite

compare2:
	ldrb r2, [r1]	// Recorre siguiente caracter
	add r1, r1, #1
	ldrb r5, [r3]	// Carga caracter de palabra a comparar
	add r3, r3, #1
	cmp r5, #0	// Si se termina recorrer palabra
	beq compare3
	cmp r2, r5
	beq compare2 // Si tienen caracter igual
	
nextWord:
	ldr r3, =palabra
	cmp r2, #0x2e	// Si se termina recorrer texto
	beq prepWrite
	cmp r2, #0xa // Si se termina de recorrer palabra actual
	beq compare2
	ldrb r2, [r1]	// Se carga siguiente caracter
	add r1, r1, #1
	b nextWord
	
compare3:
	cmp r2, #0xa // Si palabras coinciden
	beq compare1 
	cmp r2, #0x2e	// Si se termina recorrer texto
	beq compare1
	ldr r3, =palabra // Se devuelve puntero a primer caracter palabra
	b compare2

prepWrite:
	add r3, r3, r8  // Offset de tamano palabra

	mov r2, #0xd // Carriage return
	strb r2, [r3] // Se escribe despues de palabra

	add r3, r3, #1
	mov r2, #0xa // Siguiente linea
	strb r2, [r3] // Se escribe despues de CR

	mov r7, #5 // Abre o crea archivo
	ldr r0, =postpros
	mov r1, #0x441	// O_CREAT, O_WRONLY, O_APPEND
	mov r2, #0666	// read-write
	swi 0

	mov r7, #4 // Escribe palabra
	add r8, r8, #2
	mov r2, r8
	ldr r1, =palabra
	swi 0

	sub r8, r8, #2 // Regresa a tamano original palabra

	mov r7, #6 // Cierra archivo
	mov r0, r7
	swi 0

	mov r7, #5 // Abre o crea archivo
	ldr r0, =postpros
	mov r1, #0x441	// O_CREAT, O_WRONLY, O_APPEND
	mov r2, #0666	// read-write
	swi 0

	mov r2, r4
	ldr r1, =count
	strb r2, [r1]  // Guarda cantidad de repeticiones en memoria

	add r1, r1, #1
	mov r2, #0xd	// Carriage return
	strb r2, [r1]

	add r1, r1, #1
	mov r2, #0xa 	// Siguiente linea
	strb r2, [r1]

	mov r7, #4 // Escribe cantidad de repeticiones
	mov r2, #3
	ldr r1, =count
	swi 0

	mov r7, #6 // Cierra archivo
	mov r0, r7
	swi 0

cleanWord:
	ldr r3, =palabra
	ldr r1, =str1
	add r6, r6, #1 // Para ignorar /n
	add r1, r1, r6 // Offset a siguiente palabra a guardar
	mov r8, #50  // Cantidad de ceros a agregar

cleanWord2:	
	sub r8, r8, #1  // Tamano de palabra original
	mov r7, #0
	strb r7, [r3]  // Se escribe 0 en memoria
	add r3, r3, #1
	cmp r8, #0
	bne cleanWord2
	ldr r3, =palabra

resetPtr:
	mov r2, #0 // Limpieza buffer texto
	mov r4, #0 // Limpieza cantidad de repeticiones
	mov r5, #0 // Limpieza buffer palabras
	mov r8, #0 // Limpieza tamano letra
	b buscaWord // Se continua contando palabras

exit:
	mov r7, #6 // Cierra archivo
	mov r0, r7
	swi 0
	
	mov r7, #1 // Termina
	swi 0
