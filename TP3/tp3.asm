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
	msjErrorNoExisteArchivo db "ERROR: El archivo ingresado no existe, por fvor ingresar un archivo presente en el directorio actual", 0
	
	msjMayorOMenor db "Como queres que ordene tu archivo? De manera ascendenteo (1) descendente (0)?", 0
	msjRtaInvalida db "ERROR: Rta invalida, por favor responder 1 o 0", 0

	msjVerVectorInfo db "Vector: ",0
	msjVerVector db " %hhi ", 0
	msjAntesOrd db "Vector antes de ser ordenado: ",0
	;; msjVerVector db "%hhi", 0

	;; Procesamiento de archivos
	mode db "rb", 0

	;; Variables de pasar del archivo al vector
	tamanoNumero db 1	;Cada numero tiene 1 byte de longitud

	;; Vector
	vector db 4,30,50,2,18,19,65,1,6,8,90,70, 34
	longElemento db 1
	posActual db 0 
	posACambiar db 0
	cantidadElementos db 13	;Este valor lo voy a determinar cuando lea el archivo. TODO
	cantidadElementos2 db 13	;Este valor lo voy a determinar cuando lea el archivo. TODO

	;; Variable de ir de sin signo a signo
	;; bpfcs db "%o", 0
	bpfcs db "%hhi", 0
	aStr db "%s", 0

	;; Variables del ordenamiento
	corrida db 0

section 	.bss ;Seccion sin valor por defecto

	;; Funcionamiento del algoritmo
	ordenarMayor resb 1 	;Aca voy a reservar 1 o 0, 1 --> Ascendente ; 0 ---> Descendente 

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

	;; ;; Si llego hasta aca tengo el handler del archivo en handle

	sub rsp, 8
	call pedirFuncionamiento
	add rsp,8

	sub rsp, 8		;Muestro como se ve el vector antes de ordenarlo
	mov rdi, msjAntesOrd
	call puts
	add rsp,8

	sub rsp, 8
	call imprimirVector		
	add rsp,8

	;; ;; sub rsp, 8
	;; ;; call almacenarDatos	;En esta rutina voy a almacenar todos los datos que tengo guardados en handler
	;; ;; add rsp,8

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

inputInvalido:
	mov rdi, msjRtaInvalida
	sub rsp, 8
	call puts
	add rsp, 8

pedirFuncionamiento:	
	mov rdi, msjMayorOMenor
	sub rsp, 8
	call puts
	add rsp, 8

	mov rdi, ordenarMayor ;El usuario ingresa el archivo que quiere ordenar
	sub rsp, 8
	call gets
	add rsp, 8

	mov rdi, ordenarMayor
	mov rsi, bpfcs
	mov rdx, ordenarMayor 	;Lo guardo en la misma variable
	sub rsp, 8
	call sscanf
	add rsp, 8

	sub rax, rax
	mov al, byte[ordenarMayor]
	

	cmp rax, 1
	je inputValido

	cmp rax, 0
	je inputValido

	jmp inputInvalido 	;Si llegue hasta aca abajo significa que el usuario no escribio ni 1 ni 0
	
inputValido:	
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

	sub r13, r13 		;Limpio el registro 13 para mas adelante. TODO: Mejor solucion?
	mov r15, "Pp"		;Pp --> Primer corrida, en la primera corrida tengo que guardar el primer elemento del vector
	
	sub rcx, rcx
	mov cl, byte[cantidadElementos] ;TODOTODO: Sumar pos actual restar cantidad de Elementos

iteracion:	

	sub rsp, 8
	call buscarElMinimo
	add rsp, 8
	
	loop iteracion
	;; Aca deberia tener en r13 el valor minimo/maximo

	sub rsp, 8
	call hagoSwap
	add rsp, 8
	
	sub rsp, 8
	call imprimirVector
	add rsp, 8
	;; sub rbx, rbx
	;; mov rbx, 0
	mov al, byte[corrida]
	mov byte[posActual], al
	inc byte[posActual]
	inc byte[corrida]
	dec byte[cantidadElementos]
	jmp algoritmoDeOrdenamiento

ret

buscarElMinimo:	
	sub rbx,  rbx
	mov bl, byte[posActual]	;Dejo en rbx la posicion actual para la funcion desplazamiento
	
	sub rsp, 8
	call desplazamiento 	;Me devuelve en el rax el desplazamiento requerido
	add rsp, 8

	mov byte[posActual], bl ;Actualizo la posicion actual que me devuelve desplazamiento 
	
	sub r12, r12		;Esto me deja el item del vector en r12
	mov r12b, [vector + rax];

	;; Si llego aca, tengo en el r12 el valor actual
	sub rsp, 8
	call FuncionDeComparacion
	add rsp, 8

ret
	
	;; FUNCIONES AUXILIARES
	;; Funcion que calcula si tengo que 
primeraCorrida:	
	mov r13, r12
	sub r15, r15
	
FuncionDeComparacion: 		;Compara los registros rax y rbx y devuelve el correspondiente (segun el funcionamiento del programa) en el r13. TODO: QUE SOLO USE LA PARTE DE LOS 8 BITS
	cmp r15, "Pp"
	je primeraCorrida

	mov r15, [ordenarMayor]
	cmp r15, 1 		;Si esto es 1, quiero ascendente
	je ComparacionAscendete

	;; Si llego hasta aca, quiero ordenar descendete

	jmp ComparacionDescendente ;TODO: Hacer Descendente
ComparacionAscendete:	
	cmp r13, r12
	jg actualizarNuevo

	;; Si llego hasta aca, signfica que no quiero actualizar nada
	jmp FinComparacion
ComparacionDescendente:


actualizarNuevo:
	mov r13, r12
	mov r8b, byte[posActual]
	mov byte[posACambiar], r8b
	dec byte[posACambiar]	;Correcion TODO: Chequear
	
FinComparacion:	
ret

	;; Funcion que calcula el desplazamieno
desplazamiento:			;Esta funcion me deja en el rax el desplazamiento que quiero y en el rbx actualiza la localizacion. Recibe en el registro rbx la posicion actual
	;; Calcular desplazamiento en un vector (i - 1) * longElemento

	sub rax, rax		; Esta parte se encarga del i - 1
	inc rbx
	mov rax, rbx
	dec rax			;

	sub rbp, rbp		; Esta parte se encarga del (i-1) * longElemento
	mov bpl, [longElemento]	;
	imul rax, rbp		;
ret


	;; Rutina que se encarga de imprimir el vector
imprimirVector:			;TODO: No imprime el ultimo elemento
	mov rdi, msjVerVectorInfo
	sub rsp, 8
	call puts
	add rsp,8

	
	mov r12b, byte[cantidadElementos2]
	;; inc r12 		;Sumamos uno porque sino solo hace 9 corridas
loopImpresion:	
	mov rcx, r12

	mov r14, r12
	sub r13, r13
	mov r13b, byte[cantidadElementos2]
	sub r13, r14
	

	mov rbx, r13
	sub rsp, 8
	call desplazamiento
	add rsp, 8


	
	mov rdi, msjVerVector
	mov rsi, [vector + rax]
	sub rsp, 8
	call printf
	add rsp, 8

	dec r12
	mov rcx, r12
	loop loopImpresion

	
ret

hagoSwap:
	;; Aca hago el SWAP
	sub rbx, rbx
	mov bl, byte[corrida]

	mov rax, r13
	sub r13, r13
	mov r13b, [vector + rbx]
	
	mov r8b, [posACambiar] 
	mov [vector + r8], r13b
	
	mov [vector + rbx], al

ret
