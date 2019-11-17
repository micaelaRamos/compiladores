 %{
#include <conio.h>
#include <string.h>
#include "y.tab.h"
#include "arbol.c"
#include "assembler.c"

int yystopparser=0;
FILE *yyin;
char *yytext;
extern int yylineno;

char *_constante;
NodoArbol *_ptrAsignacion = NULL;
NodoArbol *_ptr_lista_asig = NULL;
NodoArbol *_ptrDeclaracion = NULL;
NodoArbol *_ptrAsignacionLinea = NULL;
NodoArbol *_ptrSentencia = NULL;
NodoArbol *_ptrArbol = NULL;
NodoArbol *_ptrBloque = NULL;
NodoArbol *_ptrHoja = NULL;
NodoArbol *_ptrConst = NULL;
NodoArbol *_ptrCont = NULL;
NodoArbol *_ptrTermino = NULL;
NodoArbol *_ptrFactor = NULL;
NodoArbol *_ptrExpr = NULL;
NodoArbol *_ptrComparador = NULL;
NodoArbol *_ptrComparacion = NULL;
NodoArbol *_ptrCondicion = NULL;
NodoArbol *_ptrSeleccion = NULL;
NodoArbol *_ptrRepeticion = NULL;
NodoArbol *_listaIds[10];
NodoArbol *_listaFcts[10];
NodoArbol *_elseSelec;
NodoArbol *_ptrCondCumplida;
NodoArbol *_ptrPrint;
NodoArbol *_ptrRead;
char *_comparador;

int _cantIds = 0;
int _cantFacts = 0;
char *_tipoVar[10];
int _contTipos = 0;
int _tipo = 1;
int ifBody = 0;
NodoArbol *ifBodyNodos[3];
int _cantBloquesIf = 0;

char *_variableADefinir[10];
int _cantVariables = 0;
NodoArbol *_expresiones[10];
int _cantExpresiones = 0;

char * intAString(int numero);
char * floatAString(double numero);
char* getTipoVariable(char * id);
char* getTipoDeOperacion(NodoArbol *nodo1, NodoArbol *nodo2);
int validarAsignacion(char *id, char *tipoExp);
void realizarAsignacionMultiple();

FILE* archivoAssembler;
FILE* archReglas;

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

%type <strVal> COMP_IGUAL
%type <strVal> MAY_IGUAL
%type <strVal> MEN_IGUAL
%type <strVal> COMP_MENOR
%type <strVal> COMP_MAY

%%
programa: bloque {printf("regla 1 \n"); fprintf(archReglas, "regla 1 \n"); _ptrArbol = _ptrBloque; guardarArbol(_ptrArbol);};       

bloque: bloque sentencia {printf("regla 2\n"); fprintf(archReglas, "regla 2\n"); if(_ptrBloque == NULL && !ifBody) 
                                                                                {
                                                                                    printf("ptrBloque = ptrSentencia;\n");
                                                                                    _ptrBloque = _ptrSentencia; 
                                                                                } 
                                                                                else 
                                                                                {
                                                                                    if(!ifBody) 
                                                                                    {
                                                                                        printf("ptrBloque = crearNodo de bloque y sentencia;\n");
                                                                                        _ptrBloque = crearNodo(";", _ptrBloque, _ptrSentencia, "");
                                                                                    } else 
                                                                                    {
                                                                                        printf("Acumulo nodos if\n");
                                                                                        ifBodyNodos[_cantBloquesIf] = _ptrSentencia;
                                                                                        _cantBloquesIf ++;
                                                                                    } 
                                                                                }};
    | sentencia {printf("regla 3\n"); fprintf(archReglas, "regla 3\n");  if(ifBody) {
                                                                            printf("Acumulo nodos if\n");
                                                                            ifBodyNodos[_cantBloquesIf] = _ptrSentencia;
                                                                            _cantBloquesIf ++;
                                                                        } 
                                                                        else
                                                                        {
                                                                            _ptrBloque = _ptrSentencia;
                                                                        }};        
   
sentencia: declaracion {printf("regla 4\n"); fprintf(archReglas, "regla 4\n");}
    | asignacion {printf("regla 5");printf("\n"); fprintf(archReglas, "regla 5\n"); _ptrSentencia = _ptrAsignacion;}         
    | seleccion {printf("regla 6");printf("\n"); fprintf(archReglas, "regla 6\n"); _ptrSentencia = _ptrSeleccion;}       
    | repeticion {printf("regla 7");printf("\n"); fprintf(archReglas, "regla 7\n"); _ptrSentencia = _ptrRepeticion;}      
    | print  {printf("regla 8");printf("\n"); fprintf(archReglas, "regla 8\n"); _ptrSentencia = _ptrPrint;}             
    | read {printf("regla 9");printf("\n"); fprintf(archReglas, "regla 9\n"); _ptrSentencia = _ptrRead;};              

declaracion: VAR CORCH_A lista_declaracion CORCH_C ENDVAR {printf("regla 10 \n"); fprintf(archReglas, "regla 10\n");}; 

lista_declaracion: tipo_var COMA lista_declaracion COMA ID {printf("regla 11"); printf("\n"); fprintf(archReglas, "regla 11\n"); insertar_tipo_en_ts(_tipoVar[_tipo], $5); _tipo++;}; 

lista_declaracion: tipo_var CORCH_C DOSPUNTOS CORCH_A ID {printf("regla 12\n"); fprintf(archReglas, "regla 12\n"); insertar_tipo_en_ts(_tipoVar[0], $5);};

tipo_var: INT {printf("regla 15");printf("\n"); fprintf(archReglas, "regla 15\n"); _tipoVar[_contTipos] = "CTE_INT"; _contTipos++;}
	| DOUBLE {printf("regla 16");printf("\n"); fprintf(archReglas, "regla 16\n"); _tipoVar[_contTipos] = "CTE_REAL"; _contTipos++;}
	| STRING {printf("regla 17");printf("\n"); fprintf(archReglas, "regla 17\n"); _tipoVar[_contTipos] = "CTE_STRING"; _contTipos++;}; 

asignacion: const_nombre {printf("regla 18");printf("\n"); fprintf(archReglas, "regla 18\n");}
	| asignacion_linea {printf("regla 19");printf("\n"); fprintf(archReglas, "regla 19\n"); _ptrAsignacion = _ptrAsignacionLinea;}
	| ID ASIG expresion {printf("regla 20");printf("\n"); fprintf(archReglas, "regla 20\n"); validarDeclaracion($1); validarAsignacion($1, _ptrExpr->tipoNodo); _ptrAsignacion = crearNodo(":=", crearHoja($1, getTipoVariable($1)), _ptrExpr, _ptrExpr->tipoNodo);};

const_nombre: CONST ID ASIG constante {printf("regla 21");printf("\n"); fprintf(archReglas, "regla 21\n"); validarDeclaracion($2); validarAsignacion($2, _ptrConst->tipoNodo); _ptrAsignacion = crearNodo(":=", crearHoja($2, getTipoVariable($2)), _ptrConst, _ptrConst->tipoNodo);};

asignacion_linea: CORCH_A lista_asig CORCH_C { printf("regla 22 \n"); fprintf(archReglas, "regla 22\n"); realizarAsignacionMultiple(); _ptrAsignacionLinea = _ptr_lista_asig;};

lista_asig: ID COMA lista_asig COMA expresion {printf("regla 23 \n"); fprintf(archReglas, "regla 23\n"); if(_cantVariables == 10)
                                                                                                        {
                                                                                                            yyerror("Excede la cantidad maxima de variables para declaracion en linea");
                                                                                                        }
                                                                                                        _variableADefinir[_cantVariables] = $1;
                                                                                                        _cantVariables++;
                                                                                                        _expresiones[_cantExpresiones] = _ptrExpr;
                                                                                                        _cantExpresiones++;
                                                                                                        };

lista_asig: ID CORCH_C ASIG CORCH_A expresion {printf("regla 24 \n"); fprintf(archReglas, "regla 24\n"); _variableADefinir[_cantVariables] = $1;
                                                                                                        _cantVariables++;
                                                                                                        _expresiones[_cantExpresiones] = _ptrExpr;
                                                                                                        _cantExpresiones++;};

seleccion: IF P_A condicion P_C LL_A cond_cumplida LL_C else_seleccion {printf("regla 25");printf("\n"); fprintf(archReglas, "regla 25\n");  _ptrSeleccion = crearNodo("if", _ptrCondicion, crearNodo("cuerpoIf", _ptrCondCumplida, _elseSelec, ""), ""); ifBody = 0; _cantBloquesIf = 0;}
    | IF P_A condicion P_C LL_A cond_cumplida LL_C {printf("regla 26");printf("\n"); fprintf(archReglas, "regla 26\n"); _ptrSeleccion = crearNodo("if", _ptrCondicion, _ptrCondCumplida, ""); ifBody = 0; _cantBloquesIf = 0;}
    | IF P_A NOT P_A condicion P_C P_C LL_A cond_cumplida LL_C {printf("regla 27");printf("\n"); fprintf(archReglas, "regla 27\n"); _ptrSeleccion = crearNodo("if", crearNodo("not", _ptrCondicion, NULL, ""), _ptrCondCumplida, ""); ifBody = 0; _cantBloquesIf = 0;}
    | IF P_A NOT P_A condicion P_C P_C LL_A cond_cumplida LL_C else_seleccion {printf("regla 28");printf("\n");  fprintf(archReglas, "regla 28\n"); _ptrSeleccion = crearNodo("if", crearNodo("not", _ptrCondicion, NULL, ""), crearNodo("cuerpoIf", _ptrCondCumplida, _elseSelec, ""), ""); ifBody = 0; _cantBloquesIf = 0;};

else_seleccion: ELSE LL_A bloque LL_C { printf("Regla 29\n"); fprintf(archReglas, "regla 29\n"); _elseSelec = ifBodyNodos[1];};

cond_cumplida: bloque { printf("Regla 30 \n"); fprintf(archReglas, "regla 30\n"); _ptrCondCumplida = ifBodyNodos[0];};

condicion: comparacion {printf("regla 31");printf("\n"); fprintf(archReglas, "regla 31\n"); _ptrCondicion = _ptrComparacion;}
    | condicion AND comparacion  {printf("regla 32");printf("\n"); fprintf(archReglas, "regla 32\n"); _ptrCondicion = crearNodo("and", _ptrCondicion, _ptrComparacion, "");}
    | condicion OR comparacion {printf("regla 33");printf("\n"); fprintf(archReglas, "regla 33\n"); _ptrCondicion = crearNodo("or", _ptrCondicion, _ptrComparacion, "");};  

comparacion: ID comparador factor {printf("regla 34");printf("\n"); fprintf(archReglas, "regla 34\n"); _ptrComparacion = crearNodo(_comparador, crearHoja($1, getTipoVariable($1)), _ptrFactor, "");};

comparador: COMP_IGUAL {printf("regla 35");printf("\n"); fprintf(archReglas, "regla 35\n"); _comparador = "=="; ifBody = 1;}
    | COMP_MAY {printf("regla 36");printf("\n"); fprintf(archReglas, "regla 36\n"); _comparador = ">"; ifBody = 1;}         
    | COMP_MENOR {printf("regla 37");printf("\n"); fprintf(archReglas, "regla 37\n"); _comparador = "<"; ifBody = 1;}        
    | MAY_IGUAL {printf("regla 38");printf("\n"); fprintf(archReglas, "regla 38\n"); _comparador = ">="; ifBody = 1;}        
    | MEN_IGUAL {printf("regla 39"); printf("\n"); fprintf(archReglas, "regla 39\n"); _comparador = "<="; ifBody = 1;};

repeticion: WHILE P_A condicion P_C bloque ENDWHILE {printf("regla 40");printf("\n"); fprintf(archReglas, "regla 40\n"); _ptrRepeticion = crearNodo("while", _ptrCondicion, ifBodyNodos[0], ""); ifBody = 0;}
    | WHILE P_A NOT condicion P_C bloque ENDWHILE {printf("regla 41");printf("\n"); fprintf(archReglas, "regla 41\n"); _ptrRepeticion = crearNodo("while", crearNodo("not", _ptrCondicion, NULL, ""), ifBodyNodos[0], ""); ifBody = 0;};

expresion: expresion SUMA termino {printf("regla 42");printf("\n"); fprintf(archReglas, "regla 42\n"); _ptrExpr = crearNodo("+", _ptrExpr, _ptrTermino, getTipoDeOperacion(_ptrTermino, _ptrFactor));}
    | expresion RESTA termino     {printf("regla 43");printf("\n"); fprintf(archReglas, "regla 43\n"); _ptrExpr = crearNodo("-", _ptrExpr, _ptrTermino, getTipoDeOperacion(_ptrTermino, _ptrFactor));}
    | termino {printf("regla 44");printf("\n"); fprintf(archReglas, "regla 44\n"); _ptrExpr = _ptrTermino;};

termino: termino MUL factor {printf("regla 45");printf("\n"); fprintf(archReglas, "regla 45\n"); _ptrTermino = crearNodo("*", _ptrTermino, _ptrFactor, getTipoDeOperacion(_ptrTermino, _ptrFactor));}
    | termino DIV factor    {printf("regla 46");printf("\n"); fprintf(archReglas, "regla 46\n"); _ptrTermino = crearNodo("/", _ptrTermino, _ptrFactor, getTipoDeOperacion(_ptrTermino, _ptrFactor));}
    | factor {printf("regla 47");printf("\n"); fprintf(archReglas, "regla 47\n"); _ptrTermino = _ptrFactor;};              

factor: P_A expresion P_C {printf("regla 48");printf("\n"); fprintf(archReglas, "regla 48\n"); _ptrFactor = _ptrExpr;}     
    | ID           {printf("regla 49"); printf("\n"); fprintf(archReglas, "regla 49\n"); _ptrFactor = crearHoja($1, getTipoVariable($1));}      
    | constante {printf("regla 50");printf("\n"); fprintf(archReglas, "regla 50\n"); _ptrFactor = _ptrConst;};          

print: PRINT P_A factor P_C {printf("regla 51");printf("\n"); fprintf(archReglas, "regla 51\n"); _ptrPrint = crearNodo("print", _ptrFactor, NULL, "");};            

read: READ ID            {printf("regla 52");printf("\n"); fprintf(archReglas, "regla 52\n"); _ptrRead = crearNodo("read", crearHoja($2, getTipoVariable($2)), NULL, "");};

constante: CTE_INT       {printf("regla 53");printf("\n"); fprintf(archReglas, "regla 53\n"); _ptrConst = crearHoja(intAString($1), "CTE_INT");}
    | CTE_REAL           {printf("regla 54");printf("\n"); fprintf(archReglas, "regla 54\n"); _ptrConst = crearHoja(floatAString($1), "CTE_REAL");}    
    | CTE_STRING         {printf("regla 55");printf("\n"); fprintf(archReglas, "regla 55\n"); _ptrConst = crearHoja($1, "CTE_STRING");};        

%%

int main(int argc,char *argv[])
{
    archReglas = fopen("./reglas.txt", "w");

    if(archReglas == NULL)
    {
        printf("Error opening file reglas!\n");
        exit(1);
    }

    inicializarArbol(_ptrArbol);
  
    if ((yyin = fopen(argv[1], "rt")) == NULL)
    {
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
    }
    else
    {
        yyparse();
        guardar_tabla_simbolos();
    }

    fclose(archReglas);

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

char* floatAString(double numero)
{
    char buffer[10] = "";
    sprintf(buffer, "%f", numero);
    return buffer;
};

char* intAString(int numero)
{
    char buffer[10] = "";
    snprintf(buffer, 10, "%d", numero);
    return buffer;
};

void realizarAsignacionMultiple() 
{
    int i;
    char *idADefinir;
    NodoArbol *expr;

    for(i = 0; i < _cantExpresiones; i++)
    {
        // Arranco desde el ultimo id porque el primero ingresado es el que el parser detecta en ultimo lugar
        idADefinir = _variableADefinir[_cantVariables - 1];
        expr = _expresiones[i];

        validarDeclaracion(idADefinir);
        validarAsignacion(idADefinir, expr->tipoNodo);
        if( i == 0)
        {
            _ptr_lista_asig = crearNodo(":=", crearHoja(idADefinir, getTipoVariable(idADefinir)), expr, expr->tipoNodo);
        }
        else
        {
            _ptr_lista_asig = crearNodo(";", _ptr_lista_asig, crearNodo(":=", crearHoja(idADefinir, getTipoVariable(idADefinir)), expr, expr->tipoNodo), "");
        }
        _cantVariables --;
    }
} 

char* getTipoVariable(char * id)
{
    char *tipo = obtener_tipo_variable(id);
    return tipo;
}

char* getTipoDeOperacion(NodoArbol *nodo1, NodoArbol *nodo2)
{
    if(!strcmp(nodo1->tipoNodo, "CTE_INT") && !strcmp(nodo2->tipoNodo, "CTE_INT"))
        return "CTE_INT";
       
    return "CTE_REAL";
}

int validarAsignacion(char *id, char *tipoExp) 
{
    if(strcmp(getTipoVariable(id), tipoExp) != 0)
    {
        yyerror("Error en la asignacion de la variable");
    }

    return 1;
}

int validarDeclaracion(char *id)
{
    int idDeclarado = verificarIdDeclarado(id);
    if(!idDeclarado){
        yyerror("ERROR variable no declarada. \n" );
    }

    return 1;
}
