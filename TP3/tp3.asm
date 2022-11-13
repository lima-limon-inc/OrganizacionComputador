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

section 	.bss ;Seccion sin valor por defecto

	;; Funcionamiento del algoritmo
	ordenarMayor resb 1 	;Aca voy a reservar 1 o 0, 1 --> Mayor; 0 ---> Menor 

	;; Variables de los archivos
	archivoAOrdenar resw 1 	;Aca voy a guardar el nombre del archivo que el usuario quiere ordenar.
	handle resb 1		;Aca voy a guardar el handler del archivo

section 	.text
main:
	sub rsp, 8
	call bienvenida		;En esta rutina voy a procesar el input que el usuario me diga (voy a verificar si el archivo existe). En esta rutina voy a darle la bienvenida al usuario
	add rsp,8
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
