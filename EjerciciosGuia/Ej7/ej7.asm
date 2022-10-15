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

; Dada una matriz de 3x3 de números almacenados en BPF c/s de 16 bits, calcule la
; traza e imprimirla por pantalla.

; Inicio (6:52 pm)
; Final (8:40 pm)
section 	.data ;Seccion con valores pre establecidos
	matriz dw 1,2,3 ;Matriz hardcodeada
	       dw 4,5,6
	       dw 7,8,9
	      

	longElemento db 2 ;(3 elementos, 2 bytes cada uno)
	longFila db 6 ; (longElemento * cantidadColumna)

	msjInicio db "Inicio del programa calcular trazaz", 0
	msjFinal db "La diagonal de la matriz vale: %hi",10,0

	acumulador dw 0 ;Aca vamos a guardar la suma de la diagonal

	desplaz dw 1 ;(16 bits)
	fila db 0 ;La primera coordenada es 1,1; pero arrancamos en 0, porque sumamos 1 ni bien arrancamos a loopear
	columna db 0

section 	.bss ;Seccion sin valor por defecto

section 	.text
main:
	mov rdi, msjInicio
	sub rsp,8
	call puts
	add rsp,8

	sub rsp,8
	call calcDesplaz
	add rsp,8
	
	mov rdi, msjFinal
	mov rsi, [acumulador]
	sub rsp,8
	call printf
	add rsp,8


ret

calcDesplaz:
; i = fila | j = columna
; (i-1) * longFila + (j-1) * longElemento
; longFila = longElemento + cantColumnas
	mov rcx, 3 ;Le metemos 3 al rcx porque queremos loopear 3 veces
sumaDiagonal:
; (i-1) * longFila + (j-1) * longElemento
; \______________/   \___________________/
;        RAX                RBX
; Calculamos el desplazamiento en dos partes. Una en un registro, la otro en otro y despues lo sumamos (:carita_fachera:)

	inc byte[fila] ;Incrementamos el valor de la fila y la columan para ir moviendonos mientras recorremos la matriz
	inc byte[columna]
	sub rax, rax ; Limpiamos basura (porque fila es 1 byte)
	mov al, [fila] ; rax = contenido de fila
	dec rax ;Le restamos 1 a rax --> (i-1)
	
	sub r14, r14 
	mov r14b, [longFila] ;Mandamos el contenido de longFila a el registro porque sino no funca imul
	imul rax, r14  ; Lo multiplicamos por la longitud fila --> (i-1) * longFila
	

        sub rbx, rbx ;Mismo que el RAX
        mov bl, [columna]
        dec rbx

	sub r14, r14
	mov r14b, [longElemento]
        imul rbx, r14
        
        add ax, bx ;Me guardo el desplazamiento en RAX
        
        ;mov [desplaz], ax ; Me guardo el contenido de RAX en desplaz

        sub r12, r12
        mov r12w, [matriz + eax] ;Muevo el contenido de la matriz mas el desplazamiento al r12

	sub r13, r13
	mov r13w, [acumulador]

	add r13, r12 ; r13 +=  r12

	mov [acumulador], r13w
	
	;Actualizamos fila y columna

        loop sumaDiagonal

ret
