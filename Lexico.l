%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <float.h>
#include "y.tab.h"
FILE  *yyin;

struct tabla_simbolos_reg {
	char *nombre;
	char *tipo;
	char *valor;
	char *longitud;
};

struct tabla_simbolos_reg tabla_simbolos[50];
int cant_reg = 0;
int regTiposVariables = 0;

// Validaciones
int validar_cte_int(int num);
int validar_cte_string(char cad[35]);
int validar_cte_real(float real);
int validar_id(char *id);
void mostrar_msje_error(char *mensaje);
int validarDeclaracionExistente(char * id);
int verificarIdDeclarado(char id[255]);
int reg_tiene_tipo(int registro);
char* validarAsignacionCorrecta(char * id , char * constante);
char* obtener_tipo_variable(char *id);

// Escritura en tabla de simbolos
void insertar_reg_en_ts(char *nombre, char *tipo, char *valor, char *longitud);
void insertar_tipo_en_ts(char* tipoVar, char *id);
int reg_existente(char *nom_reg);
int insertar_id_en_ts(char *cad);
int insertar_cteint_en_ts(int entero);
int insertar_ctereal_en_ts(float real);
int insertar_ctechar_en_ts(char *cad);
void guardar_tabla_simbolos();


%}

%option noyywrap  
%option yylineno 

DIGITO			[0-9]
LETRA			[a-zA-Z]
ID				{LETRA}({LETRA}|{DIGITO}|_)*
REAL      		{DIGITO}+"."{DIGITO}+
CTEINT       	{DIGITO}+
CTESTRING		\"[a-zA-Z0-9 ]+\"
COMENTARIO_S    "--/{LETRA}|{DIGITO}|@|<|>|!|?/--"

%%
":="		{ return ASIG;}
"+"			{ return SUMA;}
"-"			{ return RESTA;}
"*"			{ return MUL;}
"/"			{ return DIV;}
"("			{ return P_A;}
")"			{ return P_C;}
"{"			{ return LL_A;}
"}"			{ return LL_C;}
"if"		{ return IF;}
"else"		{ return ELSE;}
"=="		{ return COMP_IGUAL;}
">="		{ return MAY_IGUAL;}
"<="		{ return MEN_IGUAL;}
"<"			{ return COMP_MENOR;}
">"			{ return COMP_MAY;}
"not"		{ return NOT;}
"int"		{ return INT;}
"double"	{ return DOUBLE;}
"string"	{ return STRING;}
","			{ return COMA;}
";"			{ return PUNTO_COMA;}
"||"		{ return OR;}
"&&"		{ return AND;}
"repeat"	{ return REPEAT;}
"endrepeat"	{ return ENDREPEAT;}
"print"		{ return PRINT;}
"read"		{ return READ;}
"var"		{ return VAR;}
"endvar"	{ return ENDVAR;}
"["			{ return CORCH_A;}
"]"			{ return CORCH_C;}
":"			{ return DOSPUNTOS;}
"const"		{ return CONST;}		


{ID}			{ yylval.strVal = strdup(yytext); validar_id(yylval.strVal); insertar_id_en_ts(yylval.strVal); return ID;}
{CTESTRING}		{ yylval.strVal = strdup(yytext); validar_cte_string(yylval.strVal); insertar_ctestring_en_ts(yylval.strVal); return CTE_STRING;}
{CTEINT}		{ yylval.intVal = atoi(yytext); validar_cte_int(yylval.intVal); insertar_cteint_en_ts(yylval.intVal); return CTE_INT;}
{REAL}			{ yylval.realVal = atof(yytext); validar_cte_real(yylval.realVal); insertar_ctereal_en_ts(yylval.realVal); return CTE_REAL;}

" "
"\n"
"\t"
%%

int validar_cte_int(int num)
{
	if(num < -32768 || num > 32766)
		mostrar_msje_error("ERROR: Entero fuera de rango");

	return 1;
}

int validar_cte_string(char cad[35])
{	
	char cadena[35] = "";
	int i, j=0;

	for (i = 0; i < strlen(cad); i++)
	{
	    if (cad[i] != '"')
	    {
	        cadena[j] = cad[i];
	        j++;
	    }
	}

	if(strlen(cadena) > 30)
		mostrar_msje_error("ERROR: Constante cadena supera la cantidad de caracteres maxima");

	strcpy(cad, cadena);

	return 1;
}

int validar_cte_real(float real)
{
	if( real < 3.4E-38 || real > 3.4E+38)
		mostrar_msje_error("ERROR: Constante real fuera de rango");

	return 1;
}

int validar_id(char *id)
{
	if(strlen(id) > 20)
		mostrar_msje_error("ERROR: Identificador supera la cantidad maxima de caracteres permitida");

	return 1;
}

void mostrar_msje_error(char *mensaje)
{
	printf("%s en la linea %d\n", mensaje, yylineno);
	fprintf(stderr, "Fin de ejecucion.\n");
	system ("Pause");
	exit (1);
}

void insertar_reg_en_ts(char *nombre, char *tipo, char *valor, char *longitud)
{
	struct tabla_simbolos_reg reg;
	
	reg.nombre = nombre;
	reg.tipo = tipo;
	reg.valor = valor;
	reg.longitud = longitud;
	
	tabla_simbolos[cant_reg] = reg;
	cant_reg++;
}

void insertar_tipo_en_ts(char* tipoVar, char *id)
{	
	int registro;
	char *idABuscar = (char*) malloc(sizeof(int)+1);
	*idABuscar = '\0';
	strcat(idABuscar, "_");
	strcat(idABuscar, id);
	registro = reg_existente(idABuscar);
	if(registro != -1){
		tabla_simbolos[registro].tipo = tipoVar;
		regTiposVariables++;
	}
}

int verificarIdDeclarado(char id[255]){
	char *idABuscar = (char*) malloc(sizeof(int)+1);
	*idABuscar = '\0';

	strcat(idABuscar, "_");
	strcat(idABuscar, id);

	int registro = reg_existente(idABuscar);

	if(registro != -1) {
		 if(reg_tiene_tipo(registro)){
		 	return 1;
		 }
	}
	return 0;
}

void asignarTipoACteConNombre(char * id, char * constante) {
	char *idABuscar = (char*) malloc(sizeof(int)+1);

	*idABuscar = '\0';
	strcat(idABuscar, "_");
	strcat(idABuscar, id);

	int registroId = reg_existente(idABuscar);

	char *constABuscar = (char*) malloc(sizeof(int)+1);
	*constABuscar = '\0';
	strcat(constABuscar, "_");
	strcat(constABuscar, constante);

	int registroConst = reg_existente(constABuscar);

	tabla_simbolos[registroId].tipo = tabla_simbolos[registroConst].tipo;
}

char* validarAsignacionCorrecta(char * id , char * constante){
	char *idABuscar = (char*) malloc(sizeof(int)+1);

	*idABuscar = '\0';
	strcat(idABuscar, "_");
	strcat(idABuscar, id);

	int registroId = reg_existente(idABuscar);

	char *constABuscar = (char*) malloc(sizeof(int)+1);
	*constABuscar = '\0';
	strcat(constABuscar, "_");
	strcat(constABuscar, constante);

	int registroConst = reg_existente(constABuscar);

	char* resultado = strstr(tabla_simbolos[registroConst].tipo,tabla_simbolos[registroId].tipo);
	return resultado;
}

char * obtener_tipo_variable(char *id)
{
	char *idABuscar = (char*) malloc(sizeof(int)+1);

	*idABuscar = '\0';
	strcat(idABuscar, "_");
	strcat(idABuscar, id);

	int registro = reg_existente(idABuscar);

	if(registro == -1) {
		printf("Variable %s no declarada", id);
		exit(1);
	}
	return tabla_simbolos[registro].tipo;
}

int reg_existente(char *nom_reg)
{
	int i;
	for(i=0;i<cant_reg;i++){
		if (strcmpi(nom_reg, tabla_simbolos[i].nombre) == 0) {
			return i;
		}
	}
	return -1;
}

int reg_tiene_tipo(int registro)
{	
	if (strcmpi("", tabla_simbolos[registro].tipo) == 0){
		return 0;
	}

	return 1;
}

int insertar_id_en_ts(char *id)
{	
	char *nombre = (char*) malloc(sizeof(int)+1);
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, id);
	if (reg_existente(nombre) == -1) 
		insertar_reg_en_ts(nombre, "","","-");

	return 1;
}

int insertar_cteint_en_ts(int entero)
{
	char *valor = (char*) malloc(sizeof(int));
	itoa(entero, valor, 10);

	char *nombre = (char*) malloc(sizeof(int)+1);
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, valor);
	
	if (reg_existente(nombre) == -1)
		insertar_reg_en_ts(nombre, "INT", valor, "-");

	return 1;
}

int insertar_ctereal_en_ts(float real)
{
	char *valor = (char*) malloc(sizeof(int));
	snprintf(valor, sizeof(float), "%f", real);

	char *nombre = (char*) malloc(sizeof(float)+1);
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, valor);
	
	if (reg_existente(nombre) == -1)
		insertar_reg_en_ts(nombre, "REAL", valor, "-");

	return 1;
}

int insertar_ctestring_en_ts(char *cad)
{
	char *nombre = (char*) malloc(31 * sizeof(cad));
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, cad);

	char *longitud = (char*) malloc(10*sizeof(char));	
	itoa(strlen(cad), longitud, 10);
	
	if (reg_existente(nombre) == -1)
		insertar_reg_en_ts(nombre, "STRING", cad, longitud);

	return 1;
}

int validarDeclaracionExistente(char *id) 
{
    // Validamos si la variable esta declarada con la tabla de simbolos
    int i;
	char *nombre = (char*) malloc(31 * sizeof(id));
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, id);

    for (i = 0; i < cant_reg; i++)
    {	
        if(strcmp(tabla_simbolos[i].nombre, nombre) == 0)
            return 1;
    }

    printf("Variable %s sin declarar en la linea %d\n", id, yylineno);
	fprintf(stderr, "Fin de ejecucion.\n");
	system ("Pause");
	exit (1);
}

void guardar_tabla_simbolos()
{
	FILE *file = fopen("ts.txt", "a");
	int i = 0;

	if(file == NULL)
	{
    	printf("ERROR: No se pudo abrir el txt de la tabla de simbolos\n");
	}
	else 
	{
		for (i; i < cant_reg; i++) 
		{
			fprintf(file, "%s\t%s\t%s\t%s\n", tabla_simbolos[i].nombre, tabla_simbolos[i].tipo, tabla_simbolos[i].valor, tabla_simbolos[i].longitud);
		}		
		fclose(file);
	}
}





