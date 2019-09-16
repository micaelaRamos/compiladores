  
%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

FILE *yyin;
char *yytext;
extern int yylineno;

%}

%union {
int intVal;
double realVal;
char *strVal;
}

%token <strVal>ID <intVal>CTE_INT <strVal>CTE_STRING <realVal>CTE_REAL
%token ASIG SUMA RESTA MUL DIV
%token COMP_IGUAL MAY_IGUAL MEN_IGUAL COMP_MENOR COMP_MAY
%token IF ELSE
%token P_A P_C LL_A LL_C
%token COMA PUNTO_COMA
%token AND OR
%token INT DOUBLE STRING

%start start

%%

start: programa { printf("\n\n\tCOMPILACION EXITOSA!!\n\n\n"); } | { printf("\n El archivo 'Prueba.Txt' no tiene un programa\n"); };
programa: bloque ;
bloque: bloque sentencia { printf("\n\n\SENTENCIA EXITOSA!!\n\n\n"); };
sentencia: asignacion | seleccion;
asignacion: ID ASIG expresion;
seleccion: IF condicion LL_A sentencia LL_C ELSE LL_A sentencia LL_C | IF condicion LL_A sentencia LL_C;
condicion: comparacion | condicion AND comparacion | condicion OR comparacion;
comparacion: expresion comparador expresion;
comparador: COMP_IGUAL | COMP_MAY | COMP_MENOR | MAY_IGUAL | MEN_IGUAL;
expresion: expresion SUMA termino | expresion RESTA termino | termino;
termino: termino MUL factor | termino DIV factor | factor;
factor: expresion | ID | constante;
constante: CTE_INT | CTE_REAL | CTE_STRING;

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
