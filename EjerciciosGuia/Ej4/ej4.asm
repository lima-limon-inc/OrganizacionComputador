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
	msjError db "Error de conversion",0
	msjDato db "%hi",10,0

	formatInputFillColl     db "%hi",0

	desplaz dq 1
	longElemento db 64


section 	.bss ;Seccion sin valor por defecto
	numerosInput resb 50
	vector 	resq 15
	input resq 1
	pivote resq 1

section 	.text
main:
	mov rdi, msjaUsuario ;Le mando a la screen el mensaje de input
	sub rsp, 8
	call puts
	add rsp, 8

	mov rcx,15 ;Queremos iterar 15 veces
 loopDe15:
 	mov r12,rcx ;Me guardo el valor del rcx en el en un registro pivote

        mov rdi, numerosInput ;Mando lo que me manda la gets a numerosInput
        sub rsp, 8 ;15
        call gets ; Chau
        add rsp, 8

 	sub rsp, 8
 	call validarInput
 	add rsp, 8

 	mov rcx, r12 ;Me guardo en el rcx lo que tenia en r12 (el valor guarado antes) al rcx para que lo reste la loop

 	sub rsp, 8
 	call anadirAVector
 	add rsp, 8

 	loop loopDe15

	mov rax, 1
	mov [desplaz], rax ;Hashtag Reciclado

 	sub rsp, 8
 	call imprimirVector
 	add rsp, 8
ret

validarInput:
	mov rdi, numerosInput
	mov rsi, formatInputFillColl
	mov rdx, input ; l 3
	sub rsp,8
	call sscanf
	add rsp, 8
	cmp rax, 1
	jl errorDeConversion
ret

errorDeConversion:
	mov rdi, msjError ;Le mando a la screen el mensaje de input
	sub rsp, 8
	call puts
	add rsp, 8
ret

anadirAVector:
;Input ---> el numero
;Desplaz
;Vector
; (i -1) * longElemento
; 		64
	
	mov r13, [desplaz]
	sub r13, 1

	sub rbx, rbx ; Como vamos a pasar un dato de menor tamanio, tenemos que limpiar el registro
	mov bl, [longElemento] ;Aca longElemento es de 1 byte (por como lo escribimos en .data)

	imul r13, rbx ;me guardo el resultado en el registro 13, y despues lo multiplicopor rbx (que tengo guardado el 64)

	mov r14, [input]
	mov [vector + r13], r14

	mov rbx,[desplaz]
	inc rbx
	mov [desplaz], rbx
	
	mov r15, [vector + r13]
; [ | | | | | | | | | | | | | |  | | | | | | | | | | | ]

ret

imprimirVector:
	
	mov r13, [desplaz]
	sub r13, 1

	sub rbx, rbx ; Como vamos a pasar un dato de menor tamanio, tenemos que limpiar el registro
	mov bl, [longElemento] ;Aca longElemento es de 1 byte (por como lo escribimos en .data)

	imul r13, rbx ;me guardo el resultado en el registro 13, y despues lo multiplicopor rbx (que tengo guardado el 64)

	mov r15, [vector + r13]
	mov [pivote], r15

	mov rdi, msjDato ;Le mando a la screen el mensaje de input
	mov rsi, [pivote]
	sub rsp, 8
	call printf
	add rsp, 8
ret
