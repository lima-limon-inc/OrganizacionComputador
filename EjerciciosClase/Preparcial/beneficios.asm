;Template generado por compilame.sh

;Se cuenta con un archivo en formato binario llamado BENEFICIOS.DAT que contiene información sobre un relevamiento 
;de los tipos de beneficios para sus empleados que ofrecen las 10 empresas del rubro de tecnología más reconocidas.
;Cada registro del archivo contiene la siguiente información.
;  - Código de empresa: 1 byte en formato binario de punto fijo sin signo [1 a 10]
;  - Código de beneficio: 2 bytes en formato ASCII.  SD (Salario en dólares), KT (kit de tecnología), VE (Vacaciones extendidas),
;     TR (Trabajo Remoto), HF (horario flexible)
;Se pide realizar un programa en assembler Intel que lea el archivo y por cada registro actualice una matriz (M) de 10x5 
;donde cada fila representa a una empresa y cada columna un tipo de beneficio.  Cada elemento de M es un binario de punto fijo sin signo de 1 byte 
;que indica si la empresa ofrece el beneficio (1) o no lo ofrece (0).
;Como la información del archivo puede ser inválida, se hará uso de una rutina interna VALREG que validará los datos de cada registro descartando
;los incorrectos.
;Por último el programa deberá:
;Ingresar un código de empresa (no debe ser validado) e informar por pantalla 
; “Ofrece todos los beneficios” en caso que así sea, o “No ofrece todos los beneficio” en caso contrario


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
	file 	db "beneficios.dat",0
	mode 	db "rb",0
	msjErrorOpen 	db 	"Error de apertura de archivo",0
	handle 	dq 	0

	registro 	times 0 db ""
		codEmp 	db 0
		beneficio times 2	db ""

	vecBeneficios db "SDKTVETRHF"
	matriz 	times 50 db 0

	msjOfreceTod db "Ofrece todos los beneficios",0
	msjNoOfreceTod db "No ofrece todos los beneficios",0
msjLeyendo db "Leyendo",0

section 	.bss ;Seccion sin valor por defecto
	registroValido resb 1
	datoValido resb 1
	columna resb 1

section 	.text
main:
    sub rsp, 8
    call abrirArchivo
    add rsp, 8
    cmp qword[handle],0 ;COMO NINGUNO DE LOS OPERANDOS ES UN REGISTRO, TENEMOS QUE INDICAR CON QWORD/BYTE/WORD
    jle errorOpen

     sub rsp, 8
     call llenarMatriz
     add rsp, 8
 
     sub rsp, 8
     call cerrarArchivo
     add rsp, 8
;
;    sub rsp, 8
;    call informe
;    add rsp, 8

     jmp finPrograma

errorOpen:
    mov rdi, msjErrorOpen
    sub rsp, 8
    call puts
    add rsp, 8
ret


cerrarArchivo:
    mov rdi, [handle]
    sub rsp, 8
    call fclose
    add rsp, 8
ret

finPrograma:
ret

abrirArchivo:
	mov 	rdi,file
	mov 	rsi,mode
	sub 	rsp, 8
	call 	fopen
	add 	rsp,8
	mov 	[handle],rax ;En handle me guardo que paso con la apertura del archivo
ret

llenarMatriz:
leerRegistro:
	mov rdi, registro
	mov rsi, 3
	mov rdx, 1
	mov rcx,[handle]
	sub 	rsp, 8
	call 	fread ;Retorna la cantidad de bytes leidos
	add 	rsp,8
	cmp 	rax,0
	jle 	endOfFile

mov 	rdi, msjLeyendo
sub 	rsp, 8
call 	gets
add 	rsp,8

	sub 	rsp, 8
	call 	VALREG
	add 	rsp,8
	cmp 	byte[registroValido],"N"
	je 	leerRegistro ;Esto va a ir leyendo recursivamente hasta el EOF

	;SI ES VALIDO, actaulizo la matriz
	sub 	rsp, 8
	call 	calcularDesplaz
	add 	rsp,8
	mov 	ebx, [desplaz]
	mov 	byte[matriz + ebx], 1

	jmp 	leerRegistro
endOfFile:
ret

calcularDesplaz: ;formula de matriz 
	 

ret


VALREG:
	mov 	byte[registroValido],"N"

	sub 	rsp, 8
	call 	validarEmpresa
	add 	rsp,8
	cmp 	byte[datoValido],"N"
	je 	finValidarRegistro

	sub 	rsp, 8
	call 	validarBeneficio
	add 	rsp,8
	cmp 	byte[datoValido],"N"
	je 	finValidarRegistro

	mov 	byte[registroValido],"S"

finValidarRegistro:
ret

validarEmpresa:
	mov 	byte[datoValido],"N"
	cmp 	byte[codEmp],1
	jl 	codEmpInval
	cmp 	byte[codEmp],10
	jg 	codEmpInval
	mov 	byte[datoValido],"S"

codEmpInval:
ret

validarBeneficio:
	mov 	byte[datoValido],"S"
	mov rbx, 0 ;Desplazamiento
	mov rcx, 5
	mov byte[columna], 1
sigBeneficio:
	push rcx ; Guardo en la pila el contenido de rcx
	mov rcx,2 ;Vamos a comparar dos cosas
	mov rsi, beneficio ; lea rsi, [beneficio] iguales
	lea rdi, [vecBeneficios + rbx] ; Si o si usar lea
	repe cmpsb
	pop rcx; agarra el contenido de la pila y lo dejo

	je beneficioValido
	add rbx, 2
	inc byte[columna]
	loop sigBeneficio

	mov 	byte[datoValido],"N"
	
codBenInval:
ret
