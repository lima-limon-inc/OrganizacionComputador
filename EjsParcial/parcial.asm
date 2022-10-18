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

section 	.bss ;Seccion sin valor por defecto
	handler resb 1 ;Manejador de archivo

	registro times 0 resb 3
	codigo resb 1
	beneficio resb 2
	
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
	cmp [codigoValido], "N"
	je leerBytes
	
	mv rax, [codigo]
	mv [fila], rax ;El codigo en si mismo es la fila

	sub rsp, 8
	call ValidarBeneficio ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
	cmp [beneficioValido], "N" ;Si no es valido el beneficio, quiero volver a iterar
	je leerBytes

	; Si llega hasta aca significa que el beneficio es valido, y ya tengo la fila y la columna

	sub rsp, 8
	call calcularDesplazMatriz ;Esto nos va a devolver en el RAX el handler
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
	mov [codigoValido], "N"
	cmp [codigo], 1
	jl codigoInvalidoMensaje

	cmp [codigo], 10
	jg codigoInvalidoMensaje
	
	mov [codigoValido], "S"
ret

ValidarBeneficio:
	mov rcx, 5 ; Hay 5 beneficios habilitados
	mov [beneficioValido], "S" ;Le pongo valor default que si, si llega al final del loop, significa que el beneficio no estaba en el vector
	sub r12, r12 ; Uso el registro r12 de desplazamiento
	mov r13, [beneficio]
	sub r14, r14
chequearCada2:
	inc r14 ;Este incremento es para obtener coordenada columna
	mov [columna], r14

	cmp  r13, [vectorBeneficios + r12]
	je finIteracion



	inc r12
	inc r12 ; Este incremento es para el desplazamiento

	loop chequearCada2

	mov [beneficioValido], "N"
finIteracion:
ret

calcularDesplazMatriz:
;

ret
