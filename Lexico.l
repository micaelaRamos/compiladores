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

// Validaciones
int validar_cte_int(int num);
int validar_cte_string(char *cad);
int validar_cte_real(float real);
int validar_id(char *id);
void mostrar_msje_error();

// Escritura en tabla de simbolos
void insertar_reg_en_ts(char *nombre, char *tipo, char *valor, char *longitud);
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
REAL      {DIGITO}+"."{DIGITO}+
CTEINT       {DIGITO}+
CTESTRING	\"{LETRA}+\"
VALID_STRING    ({CARACTER}+|{DELIM})*
COMENTARIO_S    --\/{VALID_STRING}\/--

%%
"="			{ return ASIG;}
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
"while"		{ return WHILE;}
"print"		{ return PRINT;}
"read"		{ return READ;}
"var"		{ return VAR;}
"endvar"	{ return ENDVAR;}
"["			{ return CORCH_A;}
"]"			{ return CORCH_C;}
":"			{ return DOSPUNTOS;}
"const"		{ return CONST;}		


{ID}			{ yylval.strVal = strdup(yytext); validar_id(yylval.strVal); return ID;}
{CTESTRING}	{ yylval.strVal = strdup(yytext); validar_cte_string(yylval.strVal); insertar_ctestring_en_ts(yylval.strVal); return CTE_STRING;}
{CTEINT}		{ yylval.intVal = atoi(yytext); validar_cte_int(yylval.intVal); insertar_cteint_en_ts(yylval.intVal); return CTE_INT;}
{REAL}		{ yylval.realVal = atof(yytext); validar_cte_real(yylval.realVal); insertar_ctereal_en_ts(yylval.realVal); return CTE_REAL;}


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

int validar_cte_string(char *cad)
{
	if(strlen(cad) > 30)
		mostrar_msje_error("ERROR: Constante cadena supera la cantidad de caracteres maxima");

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

int reg_existente(char *nom_reg)
{
	int i;
	for(i=0;i<cant_reg;i++){
		if (strcmpi(nom_reg, tabla_simbolos[i].nombre) == 0)
			return i;
	}
	return -1;
}

int insertar_id_en_ts(char *id)
{
	if (reg_existente(id) == -1) 
		insertar_reg_en_ts(id, "","","-");

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
		insertar_reg_en_ts(nombre, "CTE_INT", valor, "-");

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
		insertar_reg_en_ts(nombre, "CTE_REAL", valor, "-");

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
		insertar_reg_en_ts(nombre, "CTE_STRING", cad, longitud);

	return 1;
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





