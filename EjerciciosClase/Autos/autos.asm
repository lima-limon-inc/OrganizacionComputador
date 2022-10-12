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
	fileListado	db	"listado.dat",0
	modeListado	db	"rb",0		;read | binario | abrir o error
	msjErrOpenLis	db	"Error en apertura de archivo Listado",0
	handleListado	dq	0

	fileSeleccion	db	"seleccion.dat",0
	modeSeleccion	db	"wb",0
	msjErrOpenSel   db	"Error en apertura de archivo seleccion",0
	handleSeleccion	dq	0

section 	.bss ;Seccion sin valor por defecto

section 	.text
main:

ret

