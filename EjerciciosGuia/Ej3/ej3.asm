;Template generado por compilame.sh

global main
; Imports de funciones de C
extern puts
extern gets
extern printf
extern sscanf

section 	.data ;Seccion con valores pre establecidos
	msjIntput db "Cuenta ingresada: %hi^%hi",10,0
	msjaUsuario db "Ingrese Base Exponente (separado por espacio)(maximo 256)",0
	msjResultado db "Resultado: %hi",10,0
	atoi 	db "%hi %hi" ;Hago con 8 bits para simplificar
	resultado dw 1

section 	.bss ;Seccion sin valor por defecto
	inputUsuario resb 300
	base resb 100
	exponente resb 100

section 	.text
main:
	mov rdi, msjaUsuario ;Muevo el mensaje al registro de primer argumento
	sub rsp, 8
	call puts
	add rsp,8

	mov rdi, inputUsuario
	sub rsp,8
	call gets
	add rsp,8

	sub rsp,8
	call transformarAInts
	add rsp,8

	mov rdi, msjIntput
	mov si,word[base]
	mov dx,word[exponente]
	sub rsp, 8
	call printf
	add rsp, 8

	sub rsp,8
	call calcularCuenta
	add rsp,8

	mov rdi, msjResultado
	mov si,word[resultado]
	sub rsp, 8
	call printf
	add rsp, 8
ret

transformarAInts:
	mov rdi, inputUsuario
	mov rsi, atoi
	mov rdx, base
	mov rcx, exponente
	sub rsp,8
	call sscanf
	add rsp, 8

ret


calcularCuenta:
	sub rcx, rcx ;Saco la basura Seguramente innecesario
	mov cx, word[exponente] ;Mando el exponente al contador
	
	sub rbx, rbx
	mov bx, word[base] ; Muevo la base al acumulador

	sub rax, rax
	mov ax, word[resultado] ; Muevo la base al acumulador

potencia:
	imul ax, bx
	loop potencia
	mov word[resultado], ax
ret

