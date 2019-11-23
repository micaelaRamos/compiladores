del ts.txt
c:\GnuWin32\bin\flex Lexico.l
pause
c:\GnuWin32\bin\bison -dyv Sintactico.y
pause
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o Grupo25.exe
pause
pause
Grupo25.exe Prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del Grupo25.exe
pause
