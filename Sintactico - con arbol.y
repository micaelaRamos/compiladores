 %{
#include <conio.h>
#include <string.h>
#include "y.tab.h"
#include "estructuraArbol.h"
#include "arbol.c"

int yystopparser=0;
FILE *yyin;
char *yytext;
extern int yylineno;

char *_constante;
NodoArbol *_ptrAsignacion;
NodoArbol *_ptrAsignacionLinea;
NodoArbol *_ptrSentencia;
NodoArbol *_ptrArbol;
NodoArbol *_ptrHoja;

char * intAString(int numero);
char * floatAString(double numero);

%}

%union {
int intVal;
double realVal;
char *strVal;
}

%token <strVal>ID <intVal>CTE_INT <strVal>CTE_STRING <realVal>CTE_REAL
%token VAR ENDVAR
%token IF ELSE WHILE ENDWHILE PRINT READ
%token P_A P_C LL_A LL_C CORCH_A CORCH_C
%token COMA PUNTO_COMA DOSPUNTOS
%token AND OR 
%right ASIG 
%left  SUMA RESTA MUL DIV 
%left  NOT
%left COMP_IGUAL MAY_IGUAL MEN_IGUAL COMP_MENOR COMP_MAY
%token INT DOUBLE STRING CONST

%%
programa: bloque {printf("regla 1");printf("\n");};         
bloque: sentencia {printf("regla 2");printf("\n");}        
    | bloque sentencia {printf("regla 3");printf("\n");};   

sentencia: declaracion {printf("regla 4");printf("\n");}
    | asignacion {printf("regla 5");printf("\n"); _ptrSentencia = _ptrAsignacion;}         
    | seleccion {printf("regla 6");printf("\n");}       
    | repeticion {printf("regla 7");printf("\n");}      
    | print  {printf("regla 8");printf("\n");}             
    | read {printf("regla 9");printf("\n");};              

declaracion: VAR CORCH_A lista_declaracion CORCH_C ENDVAR {printf("regla 10");printf("\n");}; 

lista_declaracion: tipo_var CORCH_C DOSPUNTOS CORCH_A ID {printf("regla 11");printf("\n");}; 

lista_declaracion: tipo_var COMA lista_declaracion COMA ID {printf("regla 12");printf("\n");};

tipo_var: INT {printf("regla 13");printf("\n");}
	| DOUBLE {printf("regla 14");printf("\n");}
	| STRING {printf("regla 15");printf("\n");}; 

asignacion: const_nombre {printf("regla 16");printf("\n");}
	| asignacion_linea {printf("regla 17");printf("\n");_ptrAsignacion = _ptrAsignacionLinea;} 
	| ID ASIG expresion {_ptrAsignacion = crearNodo(":=", crearHoja($1), _ptrArbol);};

const_nombre: CONST ID ASIG constante {printf("regla 18");printf("\n"); _ptrAsignacion = crearNodo(":=", crearHoja($2), _ptrArbol);};

asignacion_linea: CORCH_A lista_asignacion CORCH_C {printf("regla 19");printf("\n");};

lista_asignacion: ID CORCH_C ASIG CORCH_A expresion {printf("regla 20");printf("\n"); _ptrAsignacionLinea = crearNodo(":=", crearHoja($1), _ptrArbol);};

lista_asignacion: ID COMA lista_asignacion COMA expresion {printf("regla 21");printf("\n"); _ptrAsignacionLinea = crearNodo(";", _ptrAsignacionLinea, crearNodo(":=",crearHoja($1), _ptrHoja));};

seleccion: IF P_A condicion P_C LL_A sentencia LL_C ELSE LL_A sentencia LL_C {printf("regla 22");printf("\n");}
    | IF P_A condicion P_C LL_A sentencia LL_C {printf("regla 23");printf("\n");}
    | IF P_A NOT condicion P_C LL_A sentencia LL_C {printf("regla 24");printf("\n");}
    | IF P_A NOT condicion P_C LL_A sentencia LL_C ELSE LL_A sentencia LL_C {printf("regla 25");printf("\n");};


condicion: comparacion {printf("regla 26");printf("\n");}
    | condicion AND comparacion  {printf("regla 27");printf("\n");}
    | condicion OR comparacion {printf("regla 28");printf("\n");};  

comparacion: expresion comparador expresion {printf("regla 29");printf("\n");}; 

comparador: COMP_IGUAL {printf("regla 30");printf("\n");}
    | COMP_MAY {printf("regla 31");printf("\n");}         
    | COMP_MENOR {printf("regla 32");printf("\n");}        
    | MAY_IGUAL {printf("regla 33");printf("\n");}        
    | MEN_IGUAL {printf("regla 34"); printf("\n");};       

repeticion: WHILE P_A condicion P_C sentencia ENDWHILE {printf("regla 35");printf("\n");}
    | WHILE P_A NOT condicion P_C sentencia ENDWHILE {printf("regla 36");printf("\n");};

expresion: expresion SUMA termino {printf("regla 37");printf("\n");}
    | expresion RESTA termino     {printf("regla 38");printf("\n");}
    | termino {printf("regla 39");printf("\n");};

termino: termino MUL factor {printf("regla 40");printf("\n");_ptrNodo = crearNodo("*", $1, $3);}
    | termino DIV factor    {printf("regla 41");printf("\n");_ptrNodo = crearNodo("/", $1, $3);}
    | factor {printf("regla 42");printf("\n");};              

factor: expresion   {printf("regla 43");printf("\n");}     
    | ID           {printf("regla 44");printf("\n");}      
    | constante {printf("regla 45");printf("\n");};          

print: PRINT P_A contenido P_C {printf("regla 46");printf("\n");};

contenido: constante     {printf("regla 47");printf("\n");}
    | ID                 {printf("regla 48");printf("\n");};               

read: READ ID            {printf("regla 49");printf("\n");};

constante: CTE_INT       {printf("regla 50");printf("\n"); _ptrHoja = crearHoja(intAString($1));}
    | CTE_REAL           {printf("regla 51");printf("\n"); _ptrHoja = crearHoja(floatAString($1));}    
    | CTE_STRING         {printf("regla 52");printf("\n"); _ptrHoja = crearHoja($1);};        

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

char * floatAString(double numero)
{
    char* stringNum = (char*)malloc(sizeof(char)*(10));
    sprintf(stringNum,"%f", numero);
    return *stringNum;
};

char * intAString(int numero)
{
    char buffer[10];
    int value = 234452;
    snprintf(buffer, 10, "%d", value);
    return buffer;
};