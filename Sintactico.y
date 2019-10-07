 %{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"
#include "arbol.c"

int yystopparser=0;
FILE *yyin;
char *yytext;
extern int yylineno;



%}

%union {
int intVal;
double realVal;
char *strVal;
ptrNodoArbol arbol;
Dato tipoDeDato;
}

%token <strVal>ID <intVal>CTE_INT <strVal>CTE_STRING <realVal>CTE_REAL
%token ASIG SUMA RESTA MUL DIV VAR ENDVAR
%token COMP_IGUAL MAY_IGUAL MEN_IGUAL COMP_MENOR COMP_MAY
%token IF ELSE WHILE ENDWHILE PRINT READ
%token P_A P_C LL_A LL_C CORCH_A CORCH_C
%token COMA PUNTO_COMA DOSPUNTOS
%token AND OR NOT
%token INT DOUBLE STRING CONST

%%
programa: bloque          {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1; ptrRaiz = $<tipoDeDato.arbol>1; }}
bloque: sentencia         {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | bloque sentencia;   {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}

sentencia: declaracion    {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | asignacion          {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | seleccion           {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | repeticion          {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | print               {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | read;               {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}

declaracion: VAR lista_declaracion ENDVAR; {{$<tipoDeDato.arbol>$ = insertarNodo("VAR",&$<tipoDeDato.arbol>2,&insertarHoja($3));}}

lista_declaracion: tipo_var CORCH_C DOSPUNTOS CORCH_A ID; {{$<tipoDeDato.arbol>$ = insertarNodo("VAR",&$<tipoDeDato.arbol>2,&insertarHoja($3));}}

lista_declaracion: tipo_var COMA lista_declaracion COMA ID;

tipo_var: INT | DOUBLE | STRING; {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}

asignacion: const_nombre | asignacion_linea;

const_nombre: CONST ID ASIG constante;

asignacion_linea: CORCH_A lista_asignacion CORCH_C;

lista_asignacion: ID CORCH_C ASIG CORCH_A constante;

lista_asignacion: ID COMA lista_asignacion COMA constante;

seleccion: IF P_A condicion P_C LL_A sentencia LL_C ELSE LL_A sentencia LL_C 
    | IF P_A condicion P_C LL_A sentencia LL_C
    | IF P_A NOT condicion P_C LL_A sentencia LL_C
    | IF P_A NOT condicion P_C LL_A sentencia LL_C ELSE LL_A sentencia LL_C;


condicion: comparacion  {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | condicion AND comparacion  {{$<tipoDeDato.arbol>$ = insertarNodo("AND",&$<tipoDeDLato.arbol>1,&$<tipoDeDato.arbol>3);}}
    | condicion OR comparacion;  {{$<tipoDeDato.arbol>$ = insertarNodo("OR",&$<tipoDeDLato.arbol>1,&$<tipoDeDato.arbol>3);}}

comparacion: expresion comparador expresion; 

comparador: COMP_IGUAL  {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}
    | COMP_MAY          {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}
    | COMP_MENOR        {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}
    | MAY_IGUAL         {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}
    | MEN_IGUAL;        {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}

repeticion: WHILE P_A condicion P_C sentencia ENDWHILE 
    | WHILE P_A NOT condicion P_C sentencia ENDWHILE;

expresion: expresion SUMA termino {{$<tipoDeDato.arbol>$ = insertarNodo("SUMA",&$<tipoDeDLato.arbol>1,&$<tipoDeDato.arbol>3);}}
    | expresion RESTA termino     {{$<tipoDeDato.arbol>$ = insertarNodo("RESTA",&$<tipoDeDLato.arbol>1,&$<tipoDeDato.arbol>3);}}
    | termino;

termino: termino MUL factor {{$<tipoDeDato.arbol>$ = insertarNodo("MUL",&$<tipoDeDLato.arbol>1,&$<tipoDeDato.arbol>3);}}
    | termino DIV factor    {{$<tipoDeDato.arbol>$ = insertarNodo("DIV",&$<tipoDeDLato.arbol>1,&$<tipoDeDato.arbol>3);}}
    | factor;               {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}

factor: expresion         {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | ID                  {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}
    | constante;          {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}

print: PRINT P_A contenido P_C;

contenido: constante      {{$<tipoDeDato.arbol>$ = $<tipoDeDato.arbol>1;}}
    | ID;                 {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}

read: READ ID;

constante: CTE_INT        {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}
    | CTE_REAL            {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}
    | CTE_STRING;         {{$<tipoDeDato.arbol>$ = insertarHoja($1)}}

%%

int main(int argc,char *argv[])
{
  
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
  printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
  yyparse();
  guardar_tabla_simbolos();
  printf("-------------------Listo TS-------------------\n");
  printf("Recorriendo Arbol Post Order \n \n");
  postOrder(ptrRaiz);
  }
  fclose(yyin);
  return 0;
}

int yyerror(char *errMessage)
{
   printf("ERROR en la linea %d: %s\n",yylineno,errMessage);
   fprintf(stderr, "Fin de ejecucion.\n");
   system ("Pause");
   exit (1);
}


