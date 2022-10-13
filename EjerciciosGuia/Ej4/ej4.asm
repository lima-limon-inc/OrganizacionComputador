;Template generado por compilame.sh
global main
; Imports de funciones de C (por defecto se importan todas, comentar con ";" para excluirlas)
extern puts
extern gets
extern printf
extern sscanf
; Consigna:
; Escribir un programa que lea 15 números ingresados por teclado.
; Se pide imprimir dichos números en forma decreciente.

section 	.data ;Seccion con valores pre establecidos
	msjaUsuario db "Ingrese 15 numeros",0
;	formatInputFillColl     db "%hi %hi %hi %hi %hi %hi %hi %hi %hi %hi %hi %hi %hi %hi %hi",0
	formatInputFillColl     db "%hi %hi %hi %hi",0

section 	.bss ;Seccion sin valor por defecto
	numerosInput resw 300
	vector 	resq 15

section 	.text
main:
	mov rdi, msjaUsuario ;Le mando a la screen el mensaje de input
	sub rsp, 8
	call puts
	add rsp, 8

	mov rdi, numerosInput ;Mando lo que me manda la gets a numerosInput
	sub rsp, 8
	call gets
	add rsp, 8

	sub rsp, 8
	call validarInput
	add rsp, 8
ret

validarInput:
	mov rdi, numerosInput 
	mov rsi, formatInputFillColl
	mov rdx, vector
	sub rsp,8
	call sscanf
	add rsp, 8
	mov r10, [vector]
ret
