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
; Imports de funciones de C 
extern puts
extern gets
extern printf
extern sscanf
extern fopen
extern fread
extern fclose



section 	.data ;Seccion con valores pre establecidos

	;; Mensajes para la pantalla
	msjPedirArchivo db "Bienvenido al Ordenador 3000 Ultra, necesito que me indiques que archivo queres que ordene.", 0
	msjErrorNoExisteArchivo db "ERROR: El archivo ingresado no existe, por fvor ingresar un archivo presente en el directorio actual", 0
	
	msjMayorOMenor db "Como queres que ordene tu archivo? De manera Ascendente (1) o Descendente (0)?", 0
	msjRtaInvalida db "ERROR: Rta invalida, por favor responder 1 o 0", 0

	msjVerVectorInfo db `                 Iteracion: %hhi \n`,0
	msjVerVector db " %hhi ", 0
	msjAntesOrd db "Vector antes de ser ordenado: ",0
	msjEspacioOFlecha db " %c ", 0
	msjEspacio db " ", 0
	msjFlecha db " Test ", 0

	;; Procesamiento de archivos
	mode db "rb", 0

	;; Variables de pasar del archivo al vector
	tamanoNumero db 1	;Cada numero tiene 1 byte de longitud

	;; Variables relacionadas con el vector
	;; El vector deberia verse asi: 4,30,-50,2,18,-19,65,1,6,8,90,70

	longElemento db 1       ;Constante que representa la longitud del elemento
	posActual db 0 		;Posicion en donde se encuentra en el vecot
	posACambiar db 0 	;Posicion con la que tenemos que swapear

	;; Variable de ir de sin signo a signo
	bpfcs db "%hhi", 0 	;Formato para int de 8 bits
	aStr db "%s", 0

	;; Variables del ordenamiento
	corrida db -1 		;Por que "iteracion" del ordenamiento voy

section 	.bss ;Seccion sin valor por defecto

	;; Funcionamiento del algoritmo
	ordenarMayor resb 1 	;Aca voy a reservar 1 o 0, 1 --> Ascendente ; 0 ---> Descendente 

	;; Variables de los archivos
	archivoAOrdenar resw 1 	;Aca voy a guardar el nombre del archivo que el usuario quiere ordenar.
	handle resq 1		;Aca voy a guardar el handler del archivo

	;; Variables de pasar del archivo al vector
	numero resb 1
	numeroStr resb 1
	numeroInt resb 1

	;; Variables del vector
	vector times 30 resb 1
	cantidadElementosRestantes resb 1 ;Variable que representa la cantidad de elementos que me quedan ver en el vector
	cantidadElementosTotales resb 1	  ;Constante que representa la cantidad de elementos totales del vector
	

section 	.text
main:
	sub rsp, 8
	call bienvenida		;En esta rutina voy a procesar el input que el usuario me diga (voy a verificar si el archivo existe).
	add rsp,8

	sub rsp, 8
	call almacenarDatos	;En esta rutina voy a almacenar todos los datos que tengo guardados en handler
	add rsp,8

	sub rsp, 8 		;En esta rutina le pido al usuario que me diga como quiere que ordene el vector
	call pedirFuncionamiento
	add rsp,8

	sub rsp, 8		;Muestro como se ve el vector antes de ordenarlo
	mov rdi, msjAntesOrd
	call puts
	add rsp,8

	sub rsp, 8
	call imprimirVector	;Muestro como se ve el vector antes de ordenarlo
	add rsp,8

	inc byte[corrida] 	;Incremento el valor de la variable porque al principio se la mostre al usuario como corrida 0. Ahora la necesito usar, asique le asigno el valor de 0

	sub rsp, 8
	call algoritmoDeOrdenamiento
	add rsp, 8

ret

;; Rutinas del main	

;; Rutina de bienvenida, se encarga de saludar al usuario, le pide un archivo y corrobora que exista
errorArchivo:
	mov rdi, msjErrorNoExisteArchivo
	sub rsp, 8
	call puts		;Mensaje que le informa al usuario que no existe el archivo que paso
	add rsp, 8
bienvenida:
	mov rdi, msjPedirArchivo 
	sub rsp, 8
	call puts		;Le pido al usuario que me pase un archivo
	add rsp, 8

	mov rdi, archivoAOrdenar 
	sub rsp, 8
	call gets		;El usuario ingresa el archivo que quiere ordenar y lo  guardo en archivoAOrdenar
	add rsp, 8
	
	mov rdi, archivoAOrdenar
	mov rsi, mode
	sub rsp, 8
	call fopen 		;Abro el archivo que el usuario me paso
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
	mov rdi, numero		;Me guardo el numero del archivo en la variable "numero"
	mov rsi, 1
	mov rdx, 1
	mov rcx, [handle]
	sub rsp, 8
	call fread
	add rsp, 8
	cmp rax, 0
	jle EOF

	sub r12, r12 		;Limpio basura
	mov r12b, byte[numero]	;Guardo en el registro 12 el numero que acabo de leer

	inc byte[cantidadElementosRestantes] ;A medida que voy encontrando elementos, aumento la variable "cantidadElementosRestantes" para saber a futuro cuantos elementos tiene mi vector
	inc byte[cantidadElementosTotales] ;A medida que voy encontrando elementos, aumento la variable "cantidadElementosRestantes" para saber a futuro cuantos elementos tiene mi vector. Esta variable remane constante a lo largo del programa

	sub rbx, rbx
	mov bl, [posActual] 	;Guardo la posicion actual en ese registro porque la funcion desplazamiento recibe como argumento la posicion actual y devuelve el desplazamiento para le vector
	
	sub rsp, 8
	call desplazamiento	;Me devuelve en el rax el desplazamiento requerido
	add rsp, 8

	inc byte[posActual]	;Quiero que el proximo elemento se almacene en la proxima posicion

	mov [vector + eax], r12b ;Guardo en el vector (teniendo en cuenta el desplazamiento devuelto por desplazamiento) el valor que tengo en el registro r12
	
	jmp almacenarDatos
	
EOF:
	mov rdi, [handle]
	sub rsp, 8		;Cierro el archivo antes de salir de la rutina
	call fclose
	add rsp, 8

	mov byte[posActual], 0	;Actualizo el valor de posActual para poder usarlo despues
ret




	
algoritmoDeOrdenamiento:
	sub r13, r13 		;Limpio el registro 13 para mas adelante.
	mov r15, "Pp"		;Pp --> Primer corrida, en la primera corrida tengo que guardar el primer elemento del vector, de ahi que tiene un comportamiento diferente
	
	sub rcx, rcx
	mov cl, byte[cantidadElementosRestantes] ;Me guardo en rcx (el registro asociado al loop) la cantidad de iteracion restantes

iteracion:	

	sub rsp, 8
	call buscarElMinimo 	;Esta funcion se encarga de buscar el minimo desde donde estoy parado hasta el final
	add rsp, 8
	
	inc byte[posActual]	;Actualizo la posicion actual

	loop iteracion 		;Voy a loopear hasta no tener mas elementos restantes
	;; En esta parte del programa deberia tener en r13 el valor minimo/maximo
	sub rsp, 8
	call hagoSwap 		;Esta funcion se encarga de hacer el intercambio entre la posicion actual y el minimo/maximo
	add rsp, 8

	sub rsp, 8
	call imprimirVector 	;Muestro como quedo el vector despues del swapeo
	add rsp, 8

	inc byte[corrida] 	;A este punto, tengo que ir a la proxima corrida del programa
	mov al, byte[corrida]
	mov byte[posActual], al ;Reinicio posActual al resto del vector

	dec byte[cantidadElementosRestantes] ;Ahora hay un elemento menos que chequear


	sub r9, r9
	mov r9b, byte[corrida]
	cmp r9b, byte[cantidadElementosTotales]
	jne algoritmoDeOrdenamiento ;Sigo compranado hasta que haya recorrido todo el vector

ret

buscarElMinimo:	
	sub rbx,  rbx
	mov bl, byte[posActual]	;Guardo la posicion actual en ese registro porque la funcion desplazamiento recibe como argumento la posicion actual y devuelve el desplazamiento para le vector
	
	sub rsp, 8
	call desplazamiento 	;Me devuelve en el rax el desplazamiento requerido
	add rsp, 8
	
	sub r12, r12		;Esto me deja el item del vector en r12
	mov r12b, byte[vector + eax];

	;; Si llego aca, tengo en el r12 el valor actual
	sub rsp, 8
	call FuncionDeComparacion ;Esta es la funcion que se encarga de comparar el valor actual y el ultimo guardado
	add rsp, 8

ret
	
	;; FUNCIONES AUXILIARES
	;; Funcion que calcula si tengo que 
primeraCorrida:	
	mov r13, r12		;En la primera corrida, tengo que hacer que el ultimo mas grande/chico sea el actual 
	sub r15, r15 		;Cuando ya hice la primera corrida quiero eliminar ese valor intermedio del registro r15
	
FuncionDeComparacion: 		;Compara los registros r12 y r13 y devuelve el correspondiente (segun el funcionamiento del programa) en el r13.
	cmp r15, "Pp" 		;En la primera corrida, tengo que hacer que el ultimo mas grande/chico sea el actual
	je primeraCorrida

	mov r15b, byte[ordenarMayor]
	cmp r15, 1 		;Si esto es 1, quiero ascendente
	je ComparacionAscendete

	;; Si llego hasta aca, quiero ordenar descendete

	jmp ComparacionDescendente
ComparacionAscendete:	
	cmp r13b, r12b
	jge actualizarNuevo

	;; Si llego hasta aca, signfica que no quiero actualizar nada
	jmp FinComparacion
ComparacionDescendente:
	cmp r13b, r12b
	jle actualizarNuevo

	;; Si llego hasta aca, signfica que no quiero actualizar nada
	jmp FinComparacion
actualizarNuevo:		;Esta rutina se encarga de actualizar el ultimo mas grande/chico
	mov r13, r12
	sub r8, r8
	mov r8b, byte[posActual]
	mov byte[posACambiar], r8b
	
FinComparacion:	
ret

	;; Funcion que calcula el desplazamiento
desplazamiento:			;Esta funcion me deja en el rax el desplazamiento que quiero. Recibe en el registro rbx la posicion actual
	;; Calcular desplazamiento en un vector (i - 1) * longElemento

	sub rax, rax		
	mov rax, rbx 		; Esta parte se encarga del i - 1 
	dec rax			

	sub rbp, rbp		;
	mov bpl, byte[longElemento]	; Esta parte se encarga del (i-1) * longElemento
	imul rax, rbp		;
ret


	;; Rutina que se encarga de imprimir el vector
imprimirVector:
	mov r9, [corrida]
	inc r9 			;Incremento el valor de la corrida solo para que el usuario la vea. 

	mov rdi, msjVerVectorInfo
	mov rsi, r9
	sub rsp, 8
	call printf 		;Muestro por que corrida va el programa
	add rsp, 8

	
	mov r12b, byte[cantidadElementosTotales]
	mov rcx, r12 		;Voy a mostrar tantos items como elementos tenga el vector
loopImpresion:	
	mov r12, rcx
	
	mov r14, r12
	sub r13, r13
	mov r13b, byte[cantidadElementosTotales]
	sub r13, r14
	

	mov rbx, r13
	sub rsp, 8
	call desplazamiento
	add rsp, 8

	
	sub rsi, rsi
	mov rdi, msjVerVector
	mov sil, byte[vector + eax]
	sub rsp, 8
	call printf
	add rsp, 8

	mov rcx, r12
	loop loopImpresion 	;Hago este loop hasta no tener mas items que mostrar

	mov rdi, msjEspacio
	sub rsp, 8
	call puts
	add rsp, 8
	
ret

hagoSwap:
	;; Aca hago el SWAP
	sub r13, r13
	sub rbx, rbx
	mov bl, byte[corrida] 	;Me fijo cual es elemento que tengo que intercambiar con el minimo
	sub rsp, 8
	call desplazamiento
	add rsp, 8
	mov r13b, byte[vector + eax]	;En r13 me guardo la corrida, que es el que tengo que cambiar
	mov r8, rax 		;Me guardo el desplazamiento en el r8
	
	sub r12, r12
	sub rbx, rbx
	mov bl, byte[posACambiar]
	sub rsp, 8
	call desplazamiento
	add rsp, 8
	mov r12b, byte[vector + eax]	;En r12 me guardo el de la posicion a Cambiar

	;; Intercambio, equivalente a: a, b = b, a 
	mov byte[vector + eax], r13b
	mov byte[vector + r8], r12b

ret
