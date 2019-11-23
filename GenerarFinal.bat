@echo off
echo Creating lex.yy.c"
pause
c:\GnuWin32\bin\flex Lexico.l
echo "Creating y.tab.c"
pause
c:\GnuWin32\bin\bison -dyv --graph Sintactico.y
echo "Creating Grupo25.exe"
pause
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o Grupo25.exe
echo "Cleaning"
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
echo "DONE"
pause
cls