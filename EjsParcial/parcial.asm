;Template generado por compilame.sh
global main
; Imports de funciones de C (por defecto se importan todas, comentar con ";" para excluirlas
; beneficios.dat
; 	codigo: 1bytes BPF/ss (1 a 10)
; 	codigo beneficio: 2 bytes (SD,KT,VE,TR,HF)
; Matriz 10 x 5 
;     Cada fila 1 empresa, y cada columna un tipo de beneficio
;     Cada elemento es 1 byte BPF ss (1 si, 0 no)
;              SD      KT       VE     TR     HF
;      1      
;      2
;      3
;      4
;      5
;      6
;      7
;      8
;      9
;      10
; 
extern puts
extern gets
extern printf
extern sscanf
extern fopen
extern fwrite
extern fread
extern fclose


section 	.data ;Seccion con valores pre establecidos
	archivoInput db "beneficios.dat",0
	modeInput db "rb",0

	msjError db "Error al leer archivo", 0

	matriz times 10 db 0,0,0,0,0

	vectorBeneficios db "SDKTVETRHF"

	siLoTiene db 1
	
	registro 	times 0 db ""
		codigo 	db 0
		beneficio times 2 db ""

section 	.bss ;Seccion sin valor por defecto
	handler resb 1 ;Manejador de archivo

	fila resb 1
	columna resb 1

	codigoValido resb 1
	beneficioValido resb 1



section 	.text
main:
	mov rdi, archivoInput
	mov rsi, modeInput
	sub rsp, 8
	call fopen ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
	cmp rax, 0 
	jle errorArchivo ; Si da error vamos a la rutina errorArchivo
	mov [handler], rax

	;Si llega hasta aca, el archivo existe
leerBytes:

	mov rdi, registro ;Guardamos eso en registro, [registro] = AKT 
	mov rsi, 3 ; Leemos 3 bytes
	mov rdx, 1 ;
	mov rcx, [handler]
	sub rsp, 8
	call fread ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
	cmp rax, 0 
	jle errorContenidoArchivo ; Si da error significa que no hay mas que leer

	; Si llega hasta aca significa que hay texto por parsear
	sub rsp, 8
	call ValidarCodigo ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
	cmp byte[codigoValido], "N"
	je leerBytes
	
	sub rax, rax
	mov al, byte[codigo]
	mov byte[fila], al ;El codigo en si mismo es la fila

	sub rsp, 8
	call ValidarBeneficio ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
	cmp byte[beneficioValido], "N" ;Si no es valido el beneficio, quiero volver a iterar
	je leerBytes

	; Si llega hasta aca significa que el beneficio es valido, y ya tengo la fila y la columna

	sub rsp, 8
	call calcularDesplazMatriz 
	add rsp, 8
	
ret

errorArchivo:
	mov rdi, msjError
	sub rsp, 8
	call puts ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
ret

errorContenidoArchivo:
ret

ValidarCodigo:
	mov byte[codigoValido], "N"

	sub r15,r15
	mov r15b, byte[codigo]

	cmp byte[codigo], 1
	jl errorArchivo
;	jl codigoInvalidoMensaje

	cmp byte[codigo], 10
	jg errorArchivo
;	jg codigoInvalidoMensaje
	
	mov byte[codigoValido], "S"
ret

ValidarBeneficio:
	mov rcx, 5 ; Hay 5 beneficios habilitados
	mov byte[beneficioValido], "S" ;Le pongo valor default que si, si llega al final del loop, significa que el beneficio no estaba en el vector
	sub r12, r12 ; Uso el registro r12 de desplazamiento
	inc r12 ; La posicion inicial es 1
	imul r12, 2 ; Cada elemento son 2 bytes
	sub r13, r13
	mov r13w, word[beneficio]
	sub r14, r14
chequearCada2:
	inc r14 ;Este incremento es para obtener coordenada columna
	mov byte[columna], r14b

	mov r15, [vectorBeneficios + r12]
	cmp  r13, [vectorBeneficios + r12]
	je finIteracion



	inc r12
	inc r12 ; Este incremento es para el desplazamiento
	imul r12, 2 ; Cada elemento son 2 bytes

	loop chequearCada2

	mov byte[beneficioValido], "N"
finIteracion:
ret

calcularDesplazMatriz:
; (i-1) * longFila + (j-1) * longElemento
; \______________/   \___________________/
;        RAX                RBX
; Calculamos el desplazamiento en dos partes. Una en un registro, la otro en otro y despues lo sumamos (:carita_fachera:)
;
	sub rax, rax
	mov al, [fila]	
	dec rax ;Le resto uno ---> i - 1
	
	imul rax, 5 ; 5 elementos 1 byte cada uno

	sub rbx, rbx
	mov bl, [columna]	
	dec rax ;Le resto uno ---> j - 1
	
	imul rbx, 1 ; 5 elementos 1 byte cada uno

	add ax, bx
	
	mov rcx, 1
	mov rsi, siLoTiene
	lea rdi, [matriz + rax]
	
	rep movsb


ret
