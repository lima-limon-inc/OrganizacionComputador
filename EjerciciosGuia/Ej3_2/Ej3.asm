global main
extern puts
extern sscanf
extern printf
extern gets

; nasm Ejer_3.asm -f elf64
; gcc Ejer_3.o -no-pie
; gcc Ejer_3.o -no-pie -o suma
; ./a.out

; Ejercicio 3
;  Realizar un programa que resuelva X Y teniendo en cuenta que tanto X e Y pueden
; ser positivos o negativos.


section .data
    msjIngX      db   "Ingrese el numero X: ",0
    msjIngY      db   "Ingrese el numero Y: ",0
    msjFin       db   "El resultado de x a la y es: %li",10,0
    formatonum   db   "%li",0
    msjError     db   "ERROR",0
    res          dq   1
    resneg       db   "El resultado de x a la y es: 1/%li ",10,0
    signo        db   "P"
section .bss
    input     resb  50
    numX      resq  1
    numY      resq  1

section .text

main:
;   ---------------------------------------
   ;INGRESE EL PRIMER NUMERO Y LO GUARDO EN NUMX
    mov      rdi,msjIngX
    SUB      RSP,8
    call     printf
    add      rsp,8

    mov      rdi,input
    sub      rsp,8
    call     gets
    add      rsp,8

    sub     rsp,8
    call    ConversionDato1
    add     rsp,8


   ;---------------------------------------
   ;INGRESE EL SEGUNDO NUMERO Y LO GUARDO EN NUMY

    mov     rdi,msjIngY
    sub     rsp,8
    call    printf
    add     rsp,8

    mov     rdi,input
    sub     rsp,8
    call    gets
    add     rsp,8

    sub     rsp,8
    call    ConversionDato2
    add     rsp,8

    cmp     qword[numY],0
    je      ERROR

    cmp     qword[numY],0  ;-----> numy < 0
    jl      Y_NEGATIVO
VUELVE:

    cmp     qword[numY],1
    je      ERROR
    ;-------------------------------
    sub     rsp,8
    call    Potencia
    add     rsp,8

    cmp     byte[signo],"n"
    je      IMPRIMIR_NEGATIVO

    mov     rdi,msjFin
    sub     rsi,rsi
    mov     rsi,qword[res]
    sub     rsp,8
    call    printf
    add     rsp,8
ret

;FIN PROGRAMA PRINCIṔAL
;*************************
; RUTINAS INTERNAS
;*************************

ConversionDato1:
    mov    rdi,input
    mov    rsi,formatonum   ; -> por ejemplo lo que ingresa el usuario: 1 5 ---->  fil = 1 y col = 5
    mov    rdx,numX
    sub    rsp,8
    call   sscanf
    add    rsp,8

    cmp       rax,1
    jne       ERROR

ret

ConversionDato2:
    mov       rdi,input
    mov       rsi,formatonum   ; -> por ejemplo lo que ingresa el usuario: 1 5 ---->  fil = 1 y col = 5
    mov       rdx,numY
    sub       rsp,8
    call      sscanf
    add       rsp,8

    cmp       rax,1
    jne       ERROR

ret

Potencia:
    mov      rax,[res]
    mov      rcx,[numY] ;-----> i = NUM Y
    mov      rbx,[numX]

Multiplicar:
    imul     rax,rbx
    loop     Multiplicar ;-----> i--
    mov      [res],rax

ret

ERROR:
    mov     rdi,msjError
    sub     rsp,8
    call    puts
    add     rsp,8
ret

Y_NEGATIVO:
    mov    rax,[numY]
    imul   rax,-1

    mov    [numY],rax
    mov    byte[signo],"n"
    jmp    VUELVE
ret

IMPRIMIR_NEGATIVO:
    mov     rdi,resneg
    sub     rsi,rsi
    mov     rsi,qword[res]
    sub     rsp,8
    call    printf
    add     rsp,8

ret
