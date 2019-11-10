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
NodoArbol *_ptrAsignacion;
NodoArbol *_ptrListaAsignacion;
NodoArbol *_ptrAsignacionLinea;
NodoArbol *_ptrSentencia;
NodoArbol *_ptrArbol;
NodoArbol *_ptrBloque;
NodoArbol *_ptrHoja;
NodoArbol *_ptrConst;
NodoArbol *_ptrCont;
NodoArbol *_ptrTermino;
NodoArbol *_ptrFactor;
NodoArbol *_ptrExpr;
NodoArbol *_ptrComparador;
NodoArbol *_ptrComparacion;
NodoArbol *_ptrCondicion;
NodoArbol *_ptrSeleccion;
NodoArbol *_ptrRepeticion;
NodoArbol *_listaIds[10];
NodoArbol *_listaFcts[10];
NodoArbol *_elseSelec;
NodoArbol *_ptrCondCumplida;
NodoArbol *_ptrPrint;
NodoArbol *_ptrRead;
NodoArbol *_ptrDeclaracion;
char *_comparador;

int _cantIds = 0;
int _cantFacts = 0;
char * _tiposVariables[10];
char * _idsADeclarar[10];
int _registroTiposVariables = 0;
int _cantIdsADec = 0;

char * intAString(int numero);
char * floatAString(double numero);
NodoArbol * crearNodosAsignacion();
void agregarFactorAVec(NodoArbol * ptr);
void crearHojaIDAsignacion(char * id);
NodoArbol * crearNodosDeclaracion();

FILE* archivoAssembler;

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
programa: bloque {printf("regla 1");printf("\n"); _ptrArbol = _ptrBloque; guardarArbol(_ptrArbol); archivoAssembler = abrirArchivoAssembler(); procesarArbolParaAssembler(&_ptrArbol, archivoAssembler); crearAssembler(archivoAssembler); cerrarArchivoAssembler(archivoAssembler);};         
bloque: sentencia {printf("regla 2");printf("\n"); _ptrBloque = _ptrSentencia;}        
    | bloque sentencia {printf("regla 3");printf("\n"); _ptrBloque = crearNodo("main", _ptrBloque, _ptrSentencia);};   

sentencia: declaracion {printf("regla 4");printf("\n"); _ptrSentencia = _ptrDeclaracion;}
    | asignacion {printf("regla 5");printf("\n"); _ptrSentencia = _ptrAsignacion;}         
    | seleccion {printf("regla 6");printf("\n"); _ptrSentencia = _ptrSeleccion;}       
    | repeticion {printf("regla 7");printf("\n"); _ptrSentencia = _ptrRepeticion;}      
    | print  {printf("regla 8");printf("\n"); _ptrSentencia = _ptrPrint;}             
    | read {printf("regla 9");printf("\n"); _ptrSentencia = _ptrRead;};              

declaracion: VAR CORCH_A lista_tipo_variables CORCH_C DOSPUNTOS CORCH_A lista_declaracion CORCH_C ENDVAR {printf("regla 10 \n"); _ptrDeclaracion = crearNodosDeclaracion();}; 

lista_declaracion: lista_declaracion COMA ID {printf("regla 11");printf("\n");_idsADeclarar[_cantIdsADec] = $<strVal>3; _cantIdsADec++;}; 

lista_declaracion: ID {printf("regla 12\n"); _idsADeclarar[_cantIdsADec] = $<strVal>1; _cantIdsADec++;};

lista_tipo_variables: lista_tipo_variables COMA tipo_var {printf("regla 13 \n");};

lista_tipo_variables: tipo_var {printf("regla 14 \n");};

tipo_var: INT {printf("regla 15");printf("\n"); _tiposVariables[_registroTiposVariables] = "INT"; _registroTiposVariables++;}
	| DOUBLE {printf("regla 16");printf("\n"); _tiposVariables[_registroTiposVariables] = "REAL"; _registroTiposVariables++;}
	| STRING {printf("regla 17");printf("\n"); _tiposVariables[_registroTiposVariables] = "STRING"; _registroTiposVariables++;}; 

asignacion: const_nombre {printf("regla 18");printf("\n");}
	| asignacion_linea {printf("regla 19");printf("\n"); _ptrAsignacion = _ptrAsignacionLinea;} 
	| ID ASIG expresion {printf("regla 20");printf("\n"); _ptrAsignacion = crearNodo(":=", crearHoja($1), _ptrExpr);};

const_nombre: CONST ID ASIG constante {printf("regla 21");printf("\n"); _ptrAsignacion = crearNodo(":=", crearHoja($2), _ptrConst);};

asignacion_linea: CORCH_A lista_variables CORCH_C ASIG CORCH_A lista_factores CORCH_C { printf("regla 22 \n"); _ptrAsignacionLinea = crearNodosAsignacion();};

lista_variables: lista_variables COMA ID { printf("regla 23 "); printf("%s \n", $3); crearHojaIDAsignacion($3);};

lista_variables: ID { printf("regla 24 "); printf("%s \n", $1); crearHojaIDAsignacion($1);};

lista_factores: lista_factores COMA factor { printf("regla 25 \n"); agregarFactorAVec(_ptrFactor);}

lista_factores: factor { printf("regla 26 \n"); agregarFactorAVec(_ptrFactor);}

seleccion: IF P_A condicion P_C LL_A cond_cumplida LL_C else_seleccion {printf("regla 27");printf("\n"); _ptrSeleccion = crearNodo("else", crearNodo("if", _ptrCondicion, _ptrCondCumplida), _ptrBloque);}
    | IF P_A condicion P_C LL_A cond_cumplida LL_C {printf("regla 28");printf("\n"); _ptrSeleccion = crearNodo("if", _ptrCondicion, _ptrCondCumplida);}
    | IF P_A NOT P_A condicion P_C P_C LL_A cond_cumplida LL_C {printf("regla 29");printf("\n"); _ptrSeleccion = crearNodo("if", crearNodo("not", _ptrCondicion, NULL), _ptrCondCumplida);}
    | IF P_A NOT P_A condicion P_C P_C LL_A cond_cumplida LL_C else_seleccion {printf("regla 30");printf("\n");  _ptrSeleccion = crearNodo("else", crearNodo("if", crearNodo("not", _ptrCondicion, NULL), _ptrCondCumplida), _ptrBloque);};

else_seleccion: ELSE LL_A bloque LL_C { printf("Regla 31\n"); _elseSelec = _ptrBloque;};

cond_cumplida: bloque { printf("Regla 32 \n"); _ptrCondCumplida = _ptrBloque;};

condicion: comparacion {printf("regla 33");printf("\n"); _ptrCondicion = _ptrComparacion;}
    | condicion AND comparacion  {printf("regla 34");printf("\n"); _ptrCondicion = crearNodo("and", _ptrCondicion, _ptrComparacion);}
    | condicion OR comparacion {printf("regla 35");printf("\n"); _ptrCondicion = crearNodo("or", _ptrCondicion, _ptrComparacion);};  

comparacion: ID comparador factor {printf("regla 36");printf("\n"); _ptrComparacion = crearNodo(_comparador, crearHoja($1), _ptrFactor);};

comparador: COMP_IGUAL {printf("regla 37");printf("\n"); _comparador = "==";}
    | COMP_MAY {printf("regla 38");printf("\n"); _comparador = ">";}         
    | COMP_MENOR {printf("regla 39");printf("\n"); _comparador = "<";}        
    | MAY_IGUAL {printf("regla 40");printf("\n"); _comparador = ">=";}        
    | MEN_IGUAL {printf("regla 41"); printf("\n"); _comparador = "<=";};

repeticion: WHILE P_A condicion P_C bloque ENDWHILE {printf("regla 42");printf("\n"); _ptrRepeticion = crearNodo("while", _ptrCondicion, _ptrBloque);}
    | WHILE P_A NOT condicion P_C bloque ENDWHILE {printf("regla 43");printf("\n"); _ptrRepeticion = crearNodo("while", crearNodo("not", _ptrCondicion, NULL), _ptrBloque);};

expresion: expresion SUMA termino {printf("regla 44");printf("\n"); _ptrExpr = crearNodo("+", _ptrExpr, _ptrTermino);}
    | expresion RESTA termino     {printf("regla 45");printf("\n"); _ptrExpr = crearNodo("-", _ptrExpr, _ptrTermino);}
    | termino {printf("regla 46");printf("\n"); _ptrExpr = _ptrTermino;};

termino: termino MUL factor {printf("regla 47");printf("\n");_ptrTermino = crearNodo("*", _ptrTermino, _ptrFactor);}
    | termino DIV factor    {printf("regla 48");printf("\n");_ptrTermino = crearNodo("/", _ptrTermino, _ptrFactor);}
    | factor {printf("regla 49");printf("\n");_ptrTermino = _ptrFactor;};              

factor: P_A expresion P_C {printf("regla 50");printf("\n"); _ptrFactor = _ptrExpr;}     
    | ID           {printf("regla 51");printf("\n"); _ptrFactor = crearHoja($1);}      
    | constante {printf("regla 52");printf("\n"); _ptrFactor = _ptrConst;};          

print: PRINT P_A factor P_C {printf("regla 53");printf("\n"); _ptrPrint = crearNodo("print", _ptrFactor, NULL);};            

read: READ ID            {printf("regla 54");printf("\n"); _ptrRead = crearNodo("read", crearHoja($2), NULL);};

constante: CTE_INT       {printf("regla 55");printf("\n"); _ptrConst = crearHoja(intAString($1));}
    | CTE_REAL           {printf("regla 56");printf("\n"); _ptrConst = crearHoja(floatAString($1));}    
    | CTE_STRING         {printf("regla 57");printf("\n"); _ptrConst = crearHoja($1);};        

%%

int main(int argc,char *argv[])
{
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
    char buffer[10] = "";
    sprintf(buffer, "%f", numero);
    return buffer;
};

char * intAString(int numero)
{
    char buffer[10] = "";
    snprintf(buffer, 10, "%d", numero);
    return buffer;
};

void crearHojaIDAsignacion(char * id)
{   
    
    int idDeclarado = verificarIdDeclarado(id);
    if(!idDeclarado){
        printf("ERROR variable %s no declarada. " , id);
        fprintf(stderr, "Fin de ejecucion.\n");
        system ("Pause");
        exit (1);
    }

    if(_cantIds == 10)
    {
        printf("ERROR en la linea %d: excede la cantidad de variables posibles a asignar\n",yylineno);
        fprintf(stderr, "Fin de ejecucion.\n");
        system ("Pause");
        exit (1);
    }
    _listaIds[_cantIds] = crearHoja(id);
    _cantIds++;
}

void agregarFactorAVec(NodoArbol * ptr)
{   
    _listaFcts[_cantFacts] = ptr;
    _cantFacts++;
}

NodoArbol * crearNodosDeclaracion()
{
	int i;
	NodoArbol *aux;

	if(_registroTiposVariables != _cantIdsADec) 
	{
		printf("ERROR declaracion incorrecta, verifique la cantidad de ids a declarar");
        fprintf(stderr, "Fin de ejecucion.\n");
        system ("Pause");
        exit (1);
	}

	for(i = 0; i < _registroTiposVariables; i++)
	{
		insertar_tipo_en_ts(_tiposVariables,_idsADeclarar[i]);
		_ptrDeclaracion = crearNodo("is", crearHoja(_idsADeclarar[i]), crearHoja(_tiposVariables[i]));
		if(i == 0)
		{
			aux = _ptrDeclaracion;
		}
		else
		{
			aux = crearNodo(";", aux, _ptrDeclaracion);
		}
	}

    return aux;
}

NodoArbol * crearNodosAsignacion() 
{
    int i;
    NodoArbol *aux;

    if((int) validarAsignacionCorrecta(_listaIds[0]->valor, _listaFcts[0]->valor) == 0)
    {
    	printf("ERROR asignacion incorrecta, verifique la asignacion en la variable %s " , _listaIds[i]->valor);
        fprintf(stderr, "Fin de ejecucion.\n");
        system ("Pause");
        exit (1);
    }

    aux = crearNodo(":=", _listaIds[0], _listaFcts[0]);

    for(i = 1; i < _cantIds; i++)
    {   
    	if((int) validarAsignacionCorrecta(_listaIds[i]->valor, _listaFcts[i]->valor) == 0)
	    {
	    	printf("ERROR asignacion incorrecta, verifique la asignacion en la variable %s " , _listaIds[i]->valor);
	        fprintf(stderr, "Fin de ejecucion.\n");
	        system ("Pause");
	        exit (1);
	    }
        _ptrListaAsignacion = crearNodo(":=", _listaIds[i], _listaFcts[i]);
        aux = crearNodo(";", aux, _ptrListaAsignacion);
        
    }

    return aux;
}