;; Dado un archivo que contiene n números en BPF c/signo de 8 bits (n <= 30) se pide codificar en
;; assembler Intel 80x86 un programa que imprima por pantalla los movimientos que se realizan (por
;; ejemplo “Realizando el intercambio de valores”) y el contenido de dicho archivo ordenado en forma
;; ascendente o descendente de acuerdo a lo que elija el usuario, usando un algoritmo de ordenamiento
;; basado en el método de selección.

;; El método de ordenamiento por selección funciona seleccionando el menor elemento del vector y
;; llevándolo al principio; a continuación selecciona el siguiente menor y lo pone en la segunda posición
;; del vector y así sucesivamente.
;; Nota: no es correcto generar el archivo con un editor de textos de forma tal que cada registro sea una tira de
;; 16 caracteres 1 y 0. Se aconseja el uso de un editor hexadecimal.

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

	;; Mensajes para la pantalla
	msjPedirArchivo db "Bienvenido al Ordenador 3000 Ultra, necesito que me indiques que archivo queres que ordene.", 0
	msjErrorNoExisteArchivo db "ERROR: El archivo ingresado no existe, por favor ingresar un archivo presente en el directorio actual", 0

	;; Procesamiento de archivos
	mode db "rb", 0

	;; Variables de pasar del archivo al vector
	tamanoNumero db 1	;Cada numero tiene 1 byte de longitud

	;; Vector
	vector db 5,80,50,1,18,19,65,1,8,11
	longElemento db 1
	posActual db 0 
	minimoActual db 0
	cantidadElementos db 10	;Este valor lo voy a determinar cuando lea el archivo

	;; Variable de ir de sin signo a signo
	;; bpfcs db "%o", 0
	bpfcs db "%hhi", 0
	aStr db "%s", 0

section 	.bss ;Seccion sin valor por defecto

	;; Funcionamiento del algoritmo
	ordenarMayor resb 1 	;Aca voy a reservar 1 o 0, 1 --> Mayor; 0 ---> Menor 

	;; Variables de los archivos
	archivoAOrdenar resw 1 	;Aca voy a guardar el nombre del archivo que el usuario quiere ordenar.
	handle resb 1		;Aca voy a guardar el handler del archivo

	;; Variables de pasar del archivo al vector
	numero resb 1
	numeroStr resb 1
	numeroInt resb 1
	

section 	.text
main:
	;; sub rsp, 8
	;; call bienvenida		;En esta rutina voy a procesar el input que el usuario me diga (voy a verificar si el archivo existe). En esta rutina voy a darle la bienvenida al usuario
	;; add rsp,8

	;; Si llego hasta aca tengo el handler del archivo en handle

	;; sub rsp, 8
	;; call almacenarDatos	;En esta rutina voy a almacenar todos los datos que tengo guardados en handler
	;; add rsp,8

	sub rsp, 8
	call algoritmoDeOrdenamiento
	add rsp, 8

ret

;; Rutinas del main	

	;; Rutina de bienvenida
errorArchivo:
	mov rdi, msjErrorNoExisteArchivo
	sub rsp, 8
	call puts
	add rsp, 8
bienvenida:
	mov rdi, msjPedirArchivo
	sub rsp, 8
	call puts
	add rsp, 8


	mov rdi, archivoAOrdenar ;El usuario ingresa el archivo que quiere ordenar
	sub rsp, 8
	call gets
	add rsp, 8
	
	mov rdi, archivoAOrdenar
	mov rsi, mode
	sub rsp, 8
	call fopen
	add rsp, 8

	cmp rax, 0 		;Corroboro que el archivo exista
	jle errorArchivo	;Si no existe, vuelvo a pedirlo

	;; Si llego hasta aca, significa que el archivo existe
	mov [handle], rax 	;En handle me guardo que paso con la apertura del archivo
ret

almacenarDatos:
	sub rsi, rsi 		;Limpio el rsi para poder pasar correctamente el tamanoNumero
	
	mov rdi, numero
	mov sil, byte[tamanoNumero]
	mov rdx, 1
	mov rcx, [handle]
	sub rsp, 8
	call fread
	add rsp, 8
	cmp rax, 0
	jle EOF

	mov r12b, byte[numero]	;DEBUG para ver que onda

	;; HASTA ACA FUNCIONA
	
	;; sub rax, rax
	;; cmp rax, 0
	;; je almacenarDatos
	
	mov rdi, numero
	mov rsi, aStr
	mov rdx, numeroStr
	sub rsp, 8
	call sscanf
	add rsp, 8

	mov r12b, byte[numeroStr];DEBUG para ver que onda

	mov rdi, numeroStr
	mov rsi, bpfcs
	mov rdx, numeroInt
	sub rsp, 8
	call sscanf
	add rsp, 8

	mov r12b, byte[numeroInt];DEBUG para ver que onda
ret

EOF:
ret

algoritmoDeOrdenamiento:
	;; Calcular desplazamiento en un vector (i - 1) * longElemento

	sub rax, rax		;\
	inc byte[posActual]	; \
	mov al, [posActual]	; /
	dec rax			;/

	sub rbx, rbx		;\
	mov bl, [longElemento]	; --> (i-1) * longElemento
	imul rax, rbx		;/

	sub r12, r12
	mov r12b, [vector + rax]
buscarElSwap:	

	
ret

TEST:
ret
