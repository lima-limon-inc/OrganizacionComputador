global main
extern puts ;Indica que esto es un modulo externo
extern gets
extern printf

section 	.data
	msjIngTexto 	db 	"Ingrese un texto por teclado (max 99 caracteres)",0 ;Esto no signfica "resevame un byte para el string" (no entraria).
	msjIngCaracter 	db 	"Ingrese un caracter por teclado",0 ;Esto no signfica "resevame un byte para el string" (no entraria).
	longTexto 	dq 	0
	contadorCarac 	dq 	0
	msjLongTexto    db  "Longitud de texto: %lli",10,0

section		.bss
	texto 	resb 100 ;Reservamos 100 bytes en memoria para el texto del usaurio
	caracter resb 50

section 	.text
main:

	mov 	rdi,msjIngTexto ;Le pasamos a rdi un puntero a la direccion de msjIngTexto
	call 	puts ;Antes de llamar esto hay que cargar las cosas en los registor correspondientes

	mov rdi,texto
	call gets ;Va a imprimir lo que sea que este en el registro rdi. Esto es porque es una funcion de C que toma como primer parametro al regitro rdi

	; Pedimos el caracter al usuario
	mov 	rdi,msjIngCaracter ;Le pasamos a rdi un puntero a la direccion de msjIngTexto
	call 	puts ;Antes de llamar esto hay que cargar las cosas en los registor correspondientes

	; El usaurio pasa el caracter
	mov rdi,caracter
	call gets ;Va a imprimir lo que sea que este en el registro rdi. Esto es porque es una funcion de C que toma como primer parametro al regitro rdi

	; Calculamos la longitud
	mov 	rsi,0
compCaracter:
	cmp 	byte[texto + rsi],0 ;rsi es el registro de
	je 	finString ;Compara con respecto a cmp

	inc 	qword[longTexto] ;;Hago referencia al contenido del campo por eso los corchetes

	mov 	al,[texto + rsi]
	cmp 	al,[caracter] ; Si o si el registro tiene que se r de 8 bits porque caracter es de 1 byte
	jne 	sgteCarac  ;Jump if not equal
	add  	qword[contadorCarac],1 ;Analogo a hacer inc[contadorCarac]

sgteCarac:
	inc 	rsi
	jmp  	compCaracter
finString:
	mov 	rdi,msjLongTexto ;Primer parametro es el texto
	mov 	rsi,[longTexto]
	sub 	rax,rax
	call 	printf

ret
