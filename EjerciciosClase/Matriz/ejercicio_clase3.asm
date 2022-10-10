; Dada una matriz 5x5 con numeros enteros de 2 bytes word
; se pide solicitar u numero de fila y columna y realizar
; la sumatoria de los elementos de la fila elegida a partir de la
; de la columna elegida y mostrar por pantalla el resultado
; Se debe validar mediante una rutina interna que los datos ingresados
; por teclado sean validos.

; COMPILACION

; nasm ejercicio_clase3.asm -f elf64
; gcc ejercicio_clase3.o -no-pie
; gcc ejercicio_clase3.o -no-pie -o suma
; ./a.out


global main
extern printf
extern sscanf
extern gets
extern puts

section .data
    msjIngFilCol            db "ingrese fila (1 a 5) y columna (1 a 5) separados por un espacio: ", 0
    formatInputFillColl     db "%hi %hi",0
    msErrorInput            db "Los datos ingresados no son validos",0
    sumatoria               dd  0
    msjSumatoria            db  "La sumatoria es: %i",10,0

    ;matriz  dw    1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5 
; Estos dos son equivalentes. A pesar de que las lineas de 2's,3's,4's y 5 no tienen rotulo o 'variable', no importa. Porque todas estas son definiciones contiguas en memoria
    matriz  dw    1,1,1,1,1 ; Tenemos una matriz "hardodeada"
            dw    2,2,2,2,2
            dw    3,3,3,3,3
            dw    4,4,4,4,4
            dw    5,5,5,5,5


section .bss
    inputFilCol     resb 50
    fila            resw 1
    columna         resw 1
    inputValido     resb 1 ; S Valido N invalido    
    desplaz         resw 1

section .text

main:

    mov rdi, msjIngFilCol ;Mandamos el mensaje al registro del primer argumento para que printf lo pueda usar
    sub rsp, 8 ; Restamos 8 porque llamamos a una funcion externa. Siempre que las usemos vamos a hacer esto
    call printf
    add rsp, 8

    mov rdi, inputFilCol ; En esta variable vamos a guardar el output de gets
    sub rsp, 8
    call gets
    add rsp, 8

    sub rsp, 8
    call validarFyC ;Aca llamamos a una rutina interna, las llamamos ded la misma manera que llamamos a una funcion de c. Restamos y sumamos
    add rsp, 8

    ; Cuando salgamos de validarFyC, vamos a tener el valor guardado en inputValido. Hay que ver que tiene

    cmp byte[inputValido], "N"
    jne  continuar ; Si es distinto a N significa que es 'S', entonces quiero que el programa continua

    mov rdi, msErrorInput
    sub rsp,8
    call puts ;Aca es un print de "Dato invalidO"
    add rsp,8

    jmp main ;Vuelve al main, pseudo while loop


ret ; Fin del main

continuar:
    sub rsp,8
    call calcDesplaz ;Esta formula calcula cuanto nos tenemos que mover en la matriz
    add rsp, 8

    sub rsp,8
    call calcSumatoria
    add rsp,8

	; Queremos llevar sumatoria a string
    mov rdi, msjSumatoria
    sub rsi,rsi ;Le saco la basura al rsi
    mov esi, [sumatoria] ;como sumatoria es de 32 bits, lo mando a la parte de 32 bits

    sub rsp,8
    call printf
    add rsp,8
    
ret

validarFyC: ; Esta funcion va a validar que el input del usuario sea valido

    mov byte[inputValido], "N" ; Ya lo cargamos con invalido. Si llega al final de esta funcion, lo marcamos como valido. La funcion "invalido" se va a encargar de "salir" de esta funcion.

    mov rdi, inputFilCol ; String a convertir
    mov rsi, formatInputFillColl ; Esta variable tiene el formato al que queremos convertir.
    mov rdx, fila ; Fila y columna son los dos valores a convertir
    mov rcx, columna ; Calling convention de sscanf para covertir strings :: deja en el rax la cantidad de valores convertidos correctamente

    sub rsp, 8
    call sscanf
    add rsp,8

    cmp rax,2 ; Le pasamos un dos porque sscanf devuelve la cantidad de argumentos pasados con exito
    jl  invalido ;jump less equal. Si tenemos menos cosas convertidas, enotnces hubo un error

   ; Si llego hast6a aca significa que el input fue de al menos dos elementos, ahora tenemos que chequear que esta dentro del rango pedidio
    cmp word[fila], 1 ;Nosotros le dijimos al usuario que nos pase un numero entre 1 y 5 para la columna y la fila
    jl  invalido ;Si es menor a 1 (jump less) va a invalido
    cmp word[fila], 5
    jg  invalido ;SI esl mayor a 5 (jump greatear) entonces tambien es invalido

    cmp word[columna], 1 ;;Igual que arriba
    jl  invalido
    cmp word[columna], 5
    jg  invalido

    mov byte[inputValido], "S" ;Este seria el parametro de retorno. Si es correcto le asigno el valor S

ret

invalido: ; Esta funcion funciona de "return", significa volve para arriba en el call stack. 
    ;; printear que algo salio mal

ret

calcDesplaz:
; Aca usamos la formula de desplazamiento
; [(fila - 1) * longFila] + [(columna - 1) * longElementop]
;    
    
; Resolvemos la formula de arriba en assembly
; LO mando a un registro de 16bits
    mov bx, [fila] ; Movemos al registro bx el valor de fila
    sub bx,1 ; Le restamos uno
    imul bx,bx,10 ; Cada fila tiene una longitud de 10 bytes (5 elementos, 2 bytes cada uno)
   ;imul: 2do * 3ero ---> 1ro

    mov [desplaz],bx ;El resultado (que tengo guardado en bx) lo guardo en desplay

    mov bx, [columna] ;Mando el contenido de columna a bx
    dec bx ;Le resto 1, siguiente la formula
    imul bx,bx,2 ;La longitud de cada elemento es de dos bytes

    add [desplaz],bx ;Le sumo el segundo corchete y me lo deja en desplaz

ret

calcSumatoria:

    mov rcx, 6 ; 6 - columna ingresada me da la cantidad de veces que tengo que loopear
    sub cx, [columna] ;Columna es de 16 bits, por eso le resto a la parte de 16 bits de rcx. No puedo mezclar campos con X cantidad de bits con otros bits
    sub ebx,ebx ;Lo pongo en cero para evitar basura.
    mov bx, [desplaz] ;Tenemos que iniciar bx en desplaz, que ya lo habiamos calculado

sumarSgte:

    sub eax, eax ;El eax puede que ya tenga basura. Entonces me lo vacio
	; Cada elemento de la matriz es de 16 bits, por eso lo cargo en ax
    mov ax, [matriz + ebx] ;Lo desplazamos una cantidad variable de lugares. Por eso ponemos un registro
    add [sumatoria], eax ; A sumatoria le sumo lo que tengo en EAX. A pesar de que siempre estoy sumando cosas de 16 bits, es probable que el resultado me quede de 32. Raro seria de 64
    add ebx, 2 ;Cada elemento de la matriz tiene dos bytes, entonces me muevo dos posiciones. 
    loop sumarSgte ;Loop le resta uno al RCX


ret
