 %{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"
int yystopparser=0;
FILE *yyin;
char *yytext;
extern int yylineno;

/**** STRUCT ARBOL ****/
typedef struct _nodo {
   char dato;
   struct _nodo *derecho;
   struct _nodo *izquierdo;
} tipoNodo;
 
typedef tipoNodo *pNodo;
typedef tipoNodo *Arbol;

/**** INICIO VARIABLES  ARBOL****/

pNodo programaPtr
pNodo bloquePtr
pNodo sentenciaPtr
pNodo declaracionPtr
pNodo lisDeclaracionPtr
pNodo tipoVarPtr
pNodo asigLineaPtr
pNodo lisAsigPtr

/**** FIN VARIABLES ****/

void crearNodo(char dat,pNodo,pNodo);
void crearHoja(char dat);

%}

%union {
int intVal;
double realVal;
char *strVal;
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
programa: bloque {printf("Compilación OK\n");}
bloque: sentencia 
    | bloque sentencia;

sentencia: declaracion
    | asignacion 
    | seleccion
    | repeticion
    | print
    | read;

declaracion: VAR lista_declaracion ENDVAR;

lista_declaracion: tipo_var CORCH_C DOSPUNTOS CORCH_A ID;

lista_declaracion: tipo_var COMA lista_declaracion COMA ID;

tipo_var: INT | DOUBLE | STRING;

asignacion: const_nombre | asignacion_linea;

const_nombre: CONST ID ASIG constante;

asignacion_linea: CORCH_A lista_asignacion CORCH_C;

lista_asignacion: ID CORCH_C ASIG CORCH_A constante;

lista_asignacion: ID COMA lista_asignacion COMA constante;

seleccion: IF P_A condicion P_C LL_A sentencia LL_C ELSE LL_A sentencia LL_C 
    | IF P_A condicion P_C LL_A sentencia LL_C
    | IF P_A NOT condicion P_C LL_A sentencia LL_C
    | IF P_A NOT condicion P_C LL_A sentencia LL_C ELSE LL_A sentencia LL_C;

condicion: comparacion 
    | condicion AND comparacion 
    | condicion OR comparacion;

comparacion: expresion comparador expresion;

comparador: COMP_IGUAL 
    | COMP_MAY 
    | COMP_MENOR 
    | MAY_IGUAL 
    | MEN_IGUAL;

repeticion: WHILE P_A condicion P_C sentencia ENDWHILE 
    | WHILE P_A NOT condicion P_C sentencia ENDWHILE;

expresion: expresion SUMA termino 
    | expresion RESTA termino 
    | termino;

termino: termino MUL factor 
    | termino DIV factor 
    | factor;

factor: expresion 
    | ID 
    | constante;

print: PRINT P_A contenido P_C;

contenido: constante | ID;

read: READ ID;

constante: CTE_INT 
    | CTE_REAL 
    | CTE_STRING;

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

pNodo crearNodo(char dat , pNodo nodo1 , pNodo nodo2) {
   pNodo padre = NULL;
   pNodo actual = *a; 
}

pNodo crearHoja(char dat) {
   
}

