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

section 	.data ;Seccion con valores pre establecidos

	matriz dw 1,1,1
	       dw 1,1,1
	       dw 1,1,1
	longElemento db 2 ;(3 elementos, 2 bytes cada uno)
	longFila db 6

section 	.bss ;Seccion sin valor por defecto

section 	.text
main:

ret

calcDesplaz:
;(i-1) * longFila + (j-1) * longElemento
; longFila = longElemento + cantColumnas
ret
