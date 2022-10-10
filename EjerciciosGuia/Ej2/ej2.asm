global main
extern puts
extern gets
extern printf
extern sscanf

section 	.data
	formatNomApe 	db "%s %s",0
	formatInt 	db "%hi",0
	formatStr 	db "%s",0
	msjNomApe 	db "Ingrese nombre",0
	msjPadron 	db "Ingrese Padron",0
	msjNacimiento 	db "Ingrese fecha de nacimiento",0
	msjFinal 	db "El alumno %s %s de Padrón N° %s tiene %hi años",10,0
	anio 		dw 2022 ;anio harcodeado para hacer la cuenta

section 	.bss ;Section sin valor por defecto
	inputUsuario resb 600 
	nombre 	resb 500 ;Reservamos 100 bytes en memoria para el nombre del usaurio
	apellido 	resb 500 ;Reservamos 100 bytes en memoria para el apellido del usaurio
	padron 	resb 100 ;Reservamos 100 bytes en memoria para el padron del usaurio
	fecha 	resb 100 ;Reservamos 100 bytes en memoria para el fecha de nacimiento del usaurio
	edad 	resb 1; Reservo 1 solo byte porque la edad no "deberia" ser mayor a 256
	anioNacimiento resw 1;

section 	.text
main:
; --------- Nom Y apellido ----------
	mov rdi, msjNomApe ;Muevo el mensaje al registro de primer argumento
	sub rsp, 8
	call puts
	add rsp,8
	
	mov rdi, inputUsuario ;Muevo la variable que quiero la gets le mande el contenido
	sub rsp, 8
	call gets ; La gets me lo manda al registron rax
	add rsp, 8

	sub rsp, 8
	call separarNombreApellido
	add rsp, 8

;------------- Padron -----------------
	mov rdi, msjPadron ;Muevo el mensaje al registro de primer argumento
	sub rsp, 8
	call puts
	add rsp,8
	
	mov rdi, padron ;Muevo la variable que quiero la gets le mande el contenido. Reutilizo la variable
	sub rsp, 8
	call gets ; La gets me lo manda al registron rax
	add rsp, 8

; ------------- Edad --------------
	mov rdi, msjNacimiento
	sub rsp, 8
	call puts
	add rsp,8

	mov rdi, inputUsuario ;Esto va a ser un string ---> Lo tengo que pasar a int y despues pasarlo a int para imprirlo
	sub rsp, 8
	call gets 
	add rsp, 8

	sub rsp, 8
	call calcularEdad 
	add rsp, 8



; ----------- Fin del programa ----------------
	; Fin del programa
	mov rdi, msjFinal
	mov rsi, nombre
	mov rdx, apellido
	mov rcx, padron
	mov r8w, word[edad]
	sub rsp, 8
	call printf
	add rsp, 8
ret

separarNombreApellido:
	mov rdi, inputUsuario ;"Matias Perez"
	mov rsi, formatNomApe ; string string
	mov rdx, nombre ; Matias
	mov rcx, apellido ; Perez
	
	sub rsp,8
	call sscanf
	add rsp, 8

ret

calcularEdad:
;Calculo la edad
	mov rdi, inputUsuario
	mov rsi, formatInt
	mov rdx, anioNacimiento ;La mando al mismo lugar
	
	sub rsp,8
	call sscanf
	add rsp, 8
	
;	mov ax,word[anioNacimiento]
;	sub ax, word[anio]
	mov ax,word[anio]
	sub ax, word[anioNacimiento]

	mov word[edad], ax

;;	mov rdi,rax
;;	mov rsi, formatStr
;;	mov rdx, edad
;;
;;	sub rsp, 8
;;	call sscanf
;;	add rsp, 8
	

ret
