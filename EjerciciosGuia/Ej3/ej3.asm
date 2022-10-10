;Template generado por compilame.sh

global main
; Imports de funciones de C
;extern puts
extern gets
extern printf
;extern sscanf

section 	.data ;Seccion con valores pre establecidos
	msjIntput db "Cuenta ingresada: %s^%s"

section 	.bss ;Seccion sin valor por defecto
	base resb 1
	exponente resb 1

section 	.text
main:
	mov rdi, base
	sub rsp,8
	call gets
	add rsp,8

	mov rdi, exponente
	sub rsp,8
	call gets
	add rsp,8

	mov rdi, msjIntput
	mov rsi, base
	mov rdx, exponente
	sub rsp, 8
	call printf
	add rsp,8
ret

