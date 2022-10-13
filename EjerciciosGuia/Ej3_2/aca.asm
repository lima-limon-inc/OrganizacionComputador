;Template generado por compilame.sh
global main
; Imports de funciones de C (por defecto se importan todas, comentar con ";" para excluirlas)
extern puts
extern gets
extern printf
extern sscanf
extern fopen
extern fwrite
extern fread
extern fclose

section 	.data ;Seccion con valores pre establecidos
	fileListado	db	"listado.dat",0
	modeListado	db	"rb",0		;read | binario | abrir o error
	msjErrOpenLis	db	"Error en apertura de archivo Listado",0
	handleListado	dq	0

	fileSeleccion	db	"seleccion.dat",0
	modeSeleccion	db	"wb",0
	msjErrOpenSel   db	"Error en apertura de archivo seleccion",0
	handleSeleccion	dq	0

	regListado 	times  0   db "" ; Defino una cabezera vacia
		marca   times  10  db " " ; Si sumas todos los bytes te das cuenta que tiene long 25
		anio 	times  4   db " "
		patente times  7   db " "
		precio  times  4   db " "

	regSeleccion  		times  0  db "" 
		patenteSel   	times  7  db " " 
		precioSel    	       dd 0  

; Funcion debug
	msjAperturaOK 	dq 	"Apertura listado ok",0
	msjLeyendo 	dq 	"Leyendo",0


section 	.bss ;Seccion sin valor por defecto
	registroValido 	resb 1

section 	.text
main:
	mov 	rdi, fileListado
	mov 	rsi, modeListado
	sub 	rsp, 8
	call 	fopen ;Abro el archivo
	add 	rsp,8

	cmp 	rax,0
	jle 	errorOpenLis ;Si hubo un error, el valor de rax es menor o igual a 0
	mov 	[handleListado],rax ;Si esta en orde, guardo el handle 

mov 	rdi,msjAperturaOK
sub 	rsp,8
call 	puts
add 	rsp,8

	mov 	rdi,fileSeleccion
	mov 	rsi,modeSeleccion
	sub 	rsp, 8
	call 	fopen
	add 	rsp, 8

	cmp 	rax,0
	jle 	errorOpenSel ;Si hubo un error, el valor de rax es menor o igual a 0
	mov 	[handleSeleccion],rax ;Si esta en orde, guardo el handle 

leerRegistro:
	mov 	rdi, regListado
	mov 	rsi, 25;Tamano del bloque
	mov 	rdx, 1
	mov 	rcx, [handleListado]
	sub 	rsp,8
	call 	fread ; Usamos fread en listado porqie es binario
	add 	rsp,8
	
	cmp 	rax,0 ; Si esto es mneor o igual a 0, significa que el archivo no tiene mas datos
	jle 	closeFiles ;

mov 	rdi,msjLeyendo
sub 	rsp,8
call 	puts
add 	rsp,8


	sub 	rsp,8
	call 	validarRegistro
	add 	rsp,8

	cmp 	byte[registroValido], "N"
	je 	leerRegistro ;Si no es val;ido, voy al siguiente


	mov 	rcx,7
	mov 	rsi, patente
	mov 	rdi, patenteSel
	rep movsb ;Implicitos registros (se repite RCX veces)

	mov 	eax, [precio]
	mov 	[precioSel], eax
	
	mov 	rdi, regSeleccion
	mov 	rsi, 11 ;7 patente + 4 bytes precio
	mov 	rdx, 1	
	mov 	rcx, [handleSeleccion]

	sub 	rsp,8
	call 	fwrite
	add 	rsp,8

	jmp 	leerRegistro



	jmp finProg

errorOpenLis:
	mov 	rdi,msjErrOpenLis
	sub 	rsp,8
	call 	puts
	add 	rsp,8
	jmp 	finProg

errorOpenSel:
	mov 	rdi,msjErrOpenSel
	sub 	rsp,8
	call 	puts
	add 	rsp,8
	jmp 	closFileListado

closeFiles: ;Si llego a closeFiles, quiero cerrar los dos, por eso no hay ret al final de closeFiles
	mov 	rdi, [handleSeleccion]
	sub 	rsp,8
	call 	fclose
	add 	rsp,8

closFileListado:
	mov 	rdi, [handleListado]
	sub 	rsp,8
	call 	fclose
	add 	rsp,8
finProg:
	ret


validarRegistro:


	mov 	byte[registroValido],"S"

ret
