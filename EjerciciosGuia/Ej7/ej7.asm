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



section 	.data ;Seccion con valores pre establecidos

	matriz dw 1,1,1
	       dw 1,1,1
	       dw 1,1,1

section 	.bss ;Seccion sin valor por defecto

section 	.text
main:

ret

