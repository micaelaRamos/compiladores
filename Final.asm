include macros2.asm
include number.asm
.MODEL LARGE 
.386
.STACK 200h 
.DATA 
_var1                         		dw	?
_var2                         		db	?
_var3                         		dw	?
_1                            		dw	1
_hola                         		db	'hola'
_73                           		dw	73
_cteConNombre                 		db	?
_cte                          		db	'cte'
_cteEntera                    		dw	?
_35                           		dw	35
_2                            		dw	2
_5                            		dw	5
_52                           		dw	52
_chau                         		db	'chau'
@aux1                         		dw	?
@aux2                         		dw	?
.CODE 
MAIN:


mov AX,@DATA
mov DS,AX 
mov ES,AX 
FNINIT 

MOV R1, _1
MOV _var1, R1
MOV R1, _hola
MOV _var2, R1
MOV R1, _73
MOV _var3, R1
MOV R1, _cte
MOV _cteConNombre, R1
MOV R1, _35
MOV _cteEntera, R1
FILD var3
FCOMP 2
FSTSW AX
SAHF
FFREE
JNE
FILD var1
FCOMP 1
FSTSW AX
SAHF
FFREE
JNE
FILD 5
FILD var1
FMUL
FSTP @aux1
FFREE
FILD 1
FILD @aux1
FADD
FSTP @aux2
FFREE
MOV R1, @aux2
MOV var3, R1
MOV R1, _cteEntera
MOV _var3, R1
MOV var2
FCOMP _hola
FSTSW AX
SAHF
FFREE
JNE
FILD var1
FCOMP 2
FSTSW AX
SAHF
FFREE
JNE
FILD var3
FCOMP 52
FSTSW AX
SAHF
FFREE
JGE
MOV R1, _chau
MOV _var2, R1
repeat
FILD var1
FCOMP 1
FSTSW AX
SAHF
FFREE
JNE
MOV R1, _cteConNombre
MOV _var2, R1
	 mov AX, 4C00h 	 	 int 21h 	 END MAIN
