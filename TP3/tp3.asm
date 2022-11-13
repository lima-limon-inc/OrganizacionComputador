;Template generado por compilame.sh
/*
Dado un archivo que contiene n números en BPF c/signo de 8 bits (n <= 30) se pide codificar en
assembler Intel 80x86 un programa que imprima por pantalla los movimientos que se realizan (por
ejemplo “Realizando el intercambio de valores”) y el contenido de dicho archivo ordenado en forma
ascendente o descendente de acuerdo a lo que elija el usuario, usando un algoritmo de ordenamiento
basado en el método de selección.
procedure seleccion(int[] vector)

El método de ordenamiento por selección funciona seleccionando el menor elemento del vector y
llevándolo al principio; a continuación selecciona el siguiente menor y lo pone en la segunda posición
del vector y así sucesivamente.
Nota: no es correcto generar el archivo con un editor de textos de forma tal que cada registro sea una tira de
16 caracteres 1 y 0. Se aconseja el uso de un editor hexadecimal.
*/

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

section 	.bss ;Seccion sin valor por defecto

section 	.text
main:

ret

