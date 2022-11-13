;Se cuenta con una matriz (M) de 10x10 cuyos elementos son bpfc/s de 2 bytes.

;Por otro lado se cuenta con un archivo en formato binario llamado diagonales.dat donde cada registro representa una serie de elementos de M que forman una diagonal (en el sentido de la diagonal principal de una matriz) y cuenta con la siguiente información:
;
;    Fila vértice superior: bpf s/s de 1 byte
;
;    Columna vértice superior: bpf s/s de 1 byte
;
;    Fila vértice inferior: bpf s/s de 1 byte
;
;    Columna vértice inferior: bpf s/s de 1 byte
;
;
;Se pide realizar un programa en assembler Intel 80x86 que lea el archivo de diagonales y para cada una de ellas realice el promedio de sus elementos.
;
;Además deberá informar por pantalla el mayor promedio encontrado.
;
;Como los datos del archivo pueden ser incorrectos se deberán validar mediante el uso de una rutina interna llamada VALREG que deberá validar los 4 valores de los vértices y que efectivamente estén alineados de manera tal que formen una diagonal en el sentido indicado
;
;En la imagen se ejemplifican vértices válidos (verde) y vértices inválidos (rojo)


global main
extern puts
extern gets
extern printf
extern sscanf
extern fopen
extern fwrite
extern fread
extern fclose

section 	.data ;Seccion con valores pre establecidos
	msjError db "Diagonales invalidas",0
	
	modeInput db "rb",0
	archivoInput db "diagonales.dat",0

	matriz times 10 dw 0,0,0,0,0,0,0,0,0,0 ; Matriz 10 x 10 (esta deberia tener datos, por simplicidad la hice toda de 0)

	registro 	times 0 db ""
		filVS 	db 0
		colVS 	db 0
		filVI 	db 0
		colVI 	db 0

	nCeldas db 0
	mayorPromedio  db 0
	filaEsValida db 0
	coluEsValida db 0
	sumatoria db 0
section 	.bss ;Seccion sin valor por defecto

section 	.text
main:

	mov rdi, archivoInput
	mov rsi, modeInput
	sub rsp, 8
	call fopen ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
	cmp rax, 0 
	mov [handler], rax ; Por consigna puedo suponer que no va a haber error de archivo

	
	sub rsp, 8
	call usarHandler ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
	

ret

usarHandler:
	mov rdi, registro ;Guardamos eso en registro, [registro] = diagonales 
	mov rsi, 4 ; Leemos 4 bytes porque hay 4 bytes de informacion por registro
	mov rdx, 1 ;
	mov rcx, [handler]
	sub rsp, 8
	call fread
	add rsp, 8
	cmp rax, 0 
	jle finArchivo ;Si da error significa que no hay mas que leer 

	sub rsp, 8
	call VALREG
	add rsp, 8

	sub rsp, 8
	call hacerSuma
	add rsp, 8

	jmp usarHandler ;Quiero volver a esta parte del programa hasta que el archivo no tenga mas contenido, lo cual va a ser atrapado por "jle finArchivo"

ret

finArchivo:
ret

VALREG:
	
	mov rcx, 10 ; Como MAXIMO quiero loopear 10 veces
validarDiagonal:
	mov byte[filaEsValida], 0
	mov byte[coluEsValida], 0

	cmp [byte]filVS, 0
	jle diagonalesInvalidas ; Si el valor es menor que 0, entonces es invalida

	cmp [byte]filVS, 10
	jle diagonalesInvalidas ; Si el valor es mayor que 10,entonces es invalida

	cmp byte[colVS], 0
	jle diagonalesInvalidas ; Si el valor es menor que 0, entonces es invalida

	cmp byte[colVS], 10
	jle diagonalesInvalidas ; Si el valor es mayor que 10,entonces es invalida

	inc byte[colVS]
	inc byte[filVS] ;Avanzo 1 diagonal para abajo del vertice superior para tratar de chocarme con los vertices inferiores

	mov al, [filVS]
	cmp al, [filVI]
	je filaValida

	loop validarDiagonal ; Si no es valida la fila loopeo de una
validarColumna:
	sub rax, rax
	mov al, [colVS]
	cmp al, [colVI]
	je coluValida


hacerSuma:
	sub rax, rax
	mov al, [coluEsValida]
	sub rbx, rbx
	mov bl, [filaEsValida]

	add al, bl

	cmp rax, 2
	je diagonalesValidas ; Si no suman dos todavia no verifique que son iguales

	loop validarDiagonal
	jmp diagonalesInvalidas ; Si llegue hasta significa que las diagonales no son validas

diagonalesValidas: ;Vuelvo arriba en el call stack, para seguir el programa en el main
ret

diagonalesInvalidas:
	mov rdi, msjError
	sub rsp, 8
	call puts ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
ret

filaValida:
	mov byte[filaEsValida], 1 ; Este significa en el r14 significa que la fila es igual
	jmp validarColumna
ret

coluValida:
	mov byte[coluEsValida], 1 ; Este significa en el r14 significa que la fila es igual
	jmp validarColumna
ret


hacerSuma:
	sub rax, rax
	mov al, [colVS]
	sub rbx, rbx
	mov bl, [colVI]
	
	sub bl, al ; Columna inferior - superior me dice la cantidad de veces que tengo que loopear
	mov rcx, rbx ; Muevo ese numero al rcx
sumaDiagonal:
; (i-1) * longFila + (j-1) * longElemento
; \______________/   \___________________/
;        RAX                RBX
	sub rax, rax
	mov al, byte[filVS]
	dec rax ; i - 1
	imul rax, 20 ; 10 columnas de 2 bytes cada una


	sub rbx, rbx
	mov bl, byte[colVS]
	dec rbx ; j - 1
	imul rbx, 0 ;2 bytes cada elemento

	add rax, rbx ; En RAX voy a tener mi desplazamiento

	sub r12, r12
	mov r12w, [matriz + rax]; almaceno en r12 el contenido de la matriz con el desplazamiento

	sub r13, r13
	mov r13, [sumatoria] ; Guardo en r13 el ultimo valor de sumatoria
	add r13, r12 ;sumatoria += Celdas 
	mov [sumatoria], r13 ; Actualizo sumatoria

	inc byte[nCeldas] ; Aumento este valor para poder calcular el promedio mas adelante
	inc byte[colVS]
	inc byte[filVS]

	loop sumaDiagonal
	; Cuando llegue aca significa que complete la digonal
	sub rax, rax
	mov ax, word[sumatoria]
	idiv byte[nCeldas] ; Esto me guarda el resultado en AX
	
	cmp ax, byte[mayorPromedio]
	jg actualizarPromedio
continuarPromedio:

	
ret ;Cuando llegue aca, el programa va a seguir en el main


actualizarPromedio:
	mov [mayorPromedio], rax
	jmp continuarPromedio

finArchivo:
	mov rdi, msjError
	sub rsp, 8
	call puts ;Esto nos va a devolver en el RAX el handler
	add rsp, 8
ret

