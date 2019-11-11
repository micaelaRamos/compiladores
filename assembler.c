#include <stdio.h>
#include <stdlib.h>

typedef struct {
    char operacion[100];
    char reg1[100];
    char reg2[100];
} struct_assembler;

struct tabla_simbolos_reg {
	char *nombre;
	char *tipo;
	char *valor;
	char *longitud;
};

struct tabla_simbolos_reg tabla_simbolos[50];

struct_assembler vector_auxs_assembler[200];
int vector_auxs_assembler_cant = 0;

FILE* abrirArchivoAssembler();
void procesarArbolParaAssembler(tArbol *pa, FILE* arch);
void crearAssembler(FILE* archivoAssembler);
void operacionAssembler(tArbol *pa, char* operacion);
void asignacionAssembler(tArbol *pa);
void comparacionAssembler(tArbol *pa, char* comparador);
void cerrarArchivoAssembler(FILE* arch);
void abrir_ts_y_guardar_tabla_simbolos();
int buscar_registro_en_ts(char *nom_reg);

/**PILA struct_assembler**/
void crear_pila_struct_assembler(t_pila_struct_assembler *pp);
int poner_en_pila_struct_assembler(t_pila_struct_assembler *pp, int pi);
int sacar_de_pila_struct_assembler(t_pila_struct_assembler *pp);
int pila_vacia_struct_assembler(const t_pila_struct_assembler *pp);

t_pila_struct_assembler pilaAssembler;
t_pila_struct_assembler pilaCondicionIFAssembler;
t_pila_struct_assembler pilaCondicionREPEATAssembler;
t_pila_struct_assembler pilaElseProcesados;


FILE* abrirArchivoAssembler(){
  FILE* arch = fopen("assembler.txt", "w+");
  if(!arch){
    printf("No se pudo crear el archivo assembler.txt\n");
    return NULL;
  }

  abrir_ts_y_guardar_tabla_simbolos();
  return arch;
}

void abrir_ts_y_guardar_tabla_simbolos()
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

int buscar_registro_en_ts(char *nom_reg)
{
  int i;
  for(i=0;i<cant_reg;i++){
    if (strcmpi(nom_reg, tabla_simbolos[i].nombre) == 0)
      return i;
  }
  return -1;
}

FILE* abrirArchivoAssembler(){
  FILE* arch = fopen("assembler.txt", "w+");
  if(!arch){
    printf("No se pudo crear el archivo assembler.txt\n");
    return NULL;
  }

  return arch;
}

void crearAssembler(FILE* arch , tabla_simbolos_reg tabla_simbolo[50]){
  int i = 0;
  int j = 0;
  //principio assembler y creacion de variables
  fprintf(arch, "include macros2.struct_assembler\n");
  fprintf(arch, "include number.struct_assembler\n");
  fprintf(arch, ".MODEL LARGE \n");
  fprintf(arch, ".386\n");
  fprintf(arch, ".STACK 200h \n");
  fprintf(arch, ".DATA \n");
  while(tabla_simbolo[i].nombre != NULL){
     fprintf(arch, "%-30s\t\t\t%d\n",tabla_simbolo[i].nombre, tabla_simbolo[i].tipo);
     i++;
  }
  fprintf(arch, ".CODE \n");
  fprintf(arch, "MAIN:\n");
  fprintf(arch, "\n");
  fprintf(arch, "\n");
  fprintf(arch, "mov AX,@DATA   ;inicializa el segmento de datos\n");
  fprintf(arch, "mov DS,AX \n");
  fprintf(arch, "mov ES,AX \n");
  fprintf(arch, "FNINIT \n");;
  fprintf(arch, "\n");


  for(i=0; i < vector_auxs_assembler_cant; i++){
    if(strcmp(vector_auxs_assembler[i].reg2, "") != 0){
      fprintf(arch, "%s %s, %s\n", vector_auxs_assembler[i].operacion, vector_auxs_assembler[i].reg1, vector_auxs_assembler[i].reg2);
    } else {
      if(strcmp(vector_auxs_assembler[i].reg1, "") != 0){
      fprintf(arch, "%s %s\n", vector_auxs_assembler[i].operacion, vector_auxs_assembler[i].reg1);
      } else {
      fprintf(arch, "%s\n", vector_auxs_assembler[i].operacion);
      }
    }
  }


  fprintf(arch, "\t mov AX, 4C00h \t ");
  fprintf(arch, "\t int 21h \t ");
  fprintf(arch, "END MAIN\n");
  fclose(arch);
}

void procesarArbolParaAssembler(tArbol *pa, FILE* arch){
  struct_assembler instruccion;
  char aux[10];

  if(!*pa)
    return;
  

  if((*pa)->prtDer != NULL || (*pa)->prtIzq != NULL){ 
    if(!strcmp((*pa)->valor, "while")){
      strcpy(instruccion.operacion, "repeat");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");
      poner_en_pila_struct_assembler(&pilaAssembler, vector_auxs_assembler_cant);
      vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
      vector_auxs_assembler_cant++;

      repeatFlag = 1;
    } else if(!strcmp((*pa)->valor, "if")){
      ifFlag = 1;
    }
  }

  procesarArbolParaAssembler(&(*pa)->prtIzq, arch);
  
  if((*pa)->prtDer != NULL || (*pa)->prtIzq != NULL){ 
    if(!strcmp((*pa)->valor, "else")){
      strcpy(instruccion.operacion, "JMP");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");
      
      poner_en_pila_struct_assembler(&pilaAssembler, vector_auxs_assembler_cant);
      
      vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
      vector_auxs_assembler_cant++;

      strcpy(instruccion.operacion, "else:");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");

      vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
      vector_auxs_assembler_cant++;

      poner_en_pila_struct_assembler(&pilaElseProcesados, 1);
    }
  }

  procesarArbolParaAssembler(&(*pa)->prtDer, arch);

  if((*pa)->prtDer != NULL || (*pa)->prtIzq != NULL){ 
    if(!strcmp((*pa)->valor, "+")){
      operacionAssembler(&(*pa), "FADD");
    } else if(!strcmp((*pa)->valor, "-")){
      operacionAssembler(&(*pa), "FSUB");
    } else if(!strcmp((*pa)->valor, "*")){
      operacionAssembler(&(*pa), "FMUL");
    } else if(!strcmp((*pa)->valor, "/")){
      operacionAssembler(&(*pa), "FDIV");
    } else if(!strcmp((*pa)->valor, ":=")){
      asignacionAssembler(&(*pa));
    } else if(!strcmp((*pa)->valor, ">")){
      comparacionAssembler(&(*pa), ">");
    } else if(!strcmp((*pa)->valor, ">=")){
      comparacionAssembler(&(*pa), ">=");
    } else if(!strcmp((*pa)->valor, "<")){
      comparacionAssembler(&(*pa), "<");
    } else if(!strcmp((*pa)->valor, "<=")){
      comparacionAssembler(&(*pa), "<=");
    } else if(!strcmp((*pa)->valor, "==")){
      comparacionAssembler(&(*pa), "==");
    } else if(!strcmp((*pa)->valor, "!=")){
      comparacionAssembler(&(*pa), "!=");
    } else if(!strcmp((*pa)->valor, "IF")){
      int pos_condicion;
      int tipo_condicion;
      int jump_else;
      
      strcpy(instruccion.operacion, "endif:");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");
      
      vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
      vector_auxs_assembler_cant++;

      //Si la pila de else procesados está vacía, significa que es un if sin else
      if(!pila_vacia_struct_assembler(&pilaElseProcesados)){
        if(pila_vacia(&pilaCondicionIFAssembler)){
          jump_else = sacar_de_pila_struct_assembler(&pilaAssembler);
          strcpy(vector_auxs_assembler[jump_else].reg1, "endif");
          pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
          strcpy(vector_auxs_assembler[pos_condicion].reg1, "else");
        } else {
          tipo_condicion = sacar_de_pila_struct_assembler(&pilaCondicionIFAssembler);
          if(tipo_condicion == AND){
            pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
            strcpy(vector_auxs_assembler[pos_condicion].reg1, "else");
            pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
            strcpy(vector_auxs_assembler[pos_condicion].reg1, "else");
          }
        }
        sacar_de_pila_struct_assembler(&pilaElseProcesados);
      } else {
        if(pila_vacia_struct_assembler(&pilaCondicionIFAssembler)){
          pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
          strcpy(vector_auxs_assembler[pos_condicion].reg1, "endif");
        } else {
          tipo_condicion = sacar_de_pila_struct_assembler(&pilaCondicionIFAssembler);
          if(tipo_condicion == AND){
            pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
            strcpy(vector_auxs_assembler[pos_condicion].reg1, "endif");
            pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
            strcpy(vector_auxs_assembler[pos_condicion].reg1, "endif");
          }
        }
      }
      
      
      
    } else if(!strcmp((*pa)->valor, "REPEAT")){
      int pos_condicion;
      int pos_ini_repeat;
      int tipo_condicion;
      
      if(pila_vacia_struct_assembler(&pilaCondicionREPEATAssembler)){
        pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
        strcpy(vector_auxs_assembler[pos_condicion].reg1, "endwhile");
      } else {
        tipo_condicion = sacar_de_pila_struct_assembler(&pilaCondicionREPEATAssembler);
        if(tipo_condicion == AND){
          pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
          strcpy(vector_auxs_assembler[pos_condicion].reg1, "endwhile");
          pos_condicion = sacar_de_pila_struct_assembler(&pilaAssembler);
          strcpy(vector_auxs_assembler[pos_condicion].reg1, "endwhile");
        }
      }

      pos_ini_repeat = sacar_de_pila_struct_assembler(&pilaAssembler);
      
      strcpy(instruccion.operacion, "JMP");
      strcpy(instruccion.reg1, vector_auxs_assembler[pos_ini_repeat].operacion);
      strcpy(instruccion.reg2, "");
      
      vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
      vector_auxs_assembler_cant++;
      
      strcpy(instruccion.operacion, "endrepeat:");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");
      
      vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
      vector_auxs_assembler_cant++;
      
    } else if(!strcmp((*pa)->valor, "AND")){
      if(repeatFlag == 1){
        poner_en_pila_struct_assembler(&pilaCondicionREPEATAssembler, AND);
        repeatFlag = 0;
      } else if (ifFlag == 1){
        poner_en_pila_struct_assembler(&pilaCondicionIFAssembler, AND);
        ifFlag = 0;
      }
      
    } else if(!strcmp((*pa)->valor, "OR")){
      if(repeatFlag == 1){
        poner_en_pila_struct_assembler(&pilaCondicionREPEATAssembler, OR);
        repeatFlag = 0;
      } else if (ifFlag == 1){
        poner_en_pila_struct_assembler(&pilaCondicionIFAssembler, OR);
        ifFlag = 0;
      }
    }
  }
}

void operacionAssembler(tArbol *pa, char* operacion){
  
  char aux[10];
  char aux2[10];
  struct_assembler instruccion;

  // primero lo hago con el valor de la izquierda
  int registro = buscar_registro_en_ts((*pa)->prtIzq->valor);
  if(!strcmp(tabla_simbolos[registro].tipo == "INT")|| !strcmp(tabla_simbolos[registro].tipo == "CTE_INT")){
    strcpy(instruccion.operacion,"FILD");
  } else if (!strcmp(tabla_simbolos[registro].tipo == "REAL")|| !strcmp(tabla_simbolos[registro].tipo == "CTE_REAL")){
    strcpy(instruccion.operacion,"FLD");
  } else{
    strcpy(instruccion.operacion,"STRING");
  }
  
  /* creo que no es necesario ya que manejamos todo como char, podemos poner el valo directamente
  if(!strcmp(tipo_dato,"INT")){    
    sprintf(instruccion.reg1,"%s", (*pa)->prtIzq->info.entero);
  } else if ( ((*pa)->prtIzq->info.flotante != 0)){    
    sprintf(instruccion.reg1,"%s", (*pa)->prtIzq->info.flotante);
  } else {
    if((*pa)->prtIzq->valor[0] == '@'){
      strcpy(instruccion.reg1, (*pa)->prtIzq->valor);
    } else {
      sprintf(instruccion.reg1,"_%s", (*pa)->prtIzq->valor);
    } 
  }*/
  sprintf(instruccion.reg1,"%s", (*pa)->prtIzq->valor);
  
  strcpy(instruccion.reg2,"");
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;

  // segundo lo hago con el valor de la derecha
  registro = buscar_registro_en_ts((*pa)->prtDer->valor);
  if(!strcmp(tabla_simbolos[registro].tipo, "INT")|| !strcmp(tabla_simbolos[registro].tipo, "CTE_INT")){
    tipo_dato = "INT";
    strcpy(instruccion.operacion,"FILD");
  } else if (!strcmp(tabla_simbolos[registro].tipo, "REAL")|| !strcmp(tabla_simbolos[registro].tipo, "CTE_REAL")){
    strcpy(instruccion.operacion,"FLD");
  } else{
    strcpy(instruccion.operacion,"STRING");
  }
  
 /* idem arriba
  if ( ((*pa)->prtDer->info.entero != 0)){
    sprintf(instruccion.reg1, "%d", (*pa)->prtDer->info.entero);
  } else if ( ((*pa)->prtDer->info.flotante != 0)) {
    sprintf(instruccion.reg1, "%f", (*pa)->prtDer->info.flotante);
  } else {
    if((*pa)->prtIzq->valor[0] == '@'){
      strcpy(instruccion.reg1, (*pa)->prtDer->valor);
    } else {
      sprintf(instruccion.reg1,"_%s", (*pa)->prtDer->valor);
    } 
  }*/
  sprintf(instruccion.reg1,"%s", (*pa)->prtDer->valor);

  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;

  strcpy(instruccion.operacion, operacion);
  strcpy(instruccion.reg1,"");
  strcpy(instruccion.reg2,"");
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;

  contAssembler++;
  strcpy(aux, "@aux");
  sprintf(aux2, "%d", contAssembler);
  strcat(aux, aux2);
  //insertarEnTabla(aux,indice_tabla,(*pa)->info.tipoDato);

  strcpy(instruccion.operacion, "FSTP");
  strcpy(instruccion.reg2,"");
  strcpy(instruccion.reg1, aux);
  strcpy(auxAssembler, aux);
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;

  strcpy(instruccion.operacion, "FFREE");
  strcpy(instruccion.reg1,"");
  strcpy(instruccion.reg2,"");
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;
    
  strcpy(instruccion.operacion, "");  
  (*pa)->prtDer = NULL;
  (*pa)->prtIzq = NULL;
  strcpy((*pa)->valor,auxAssembler);
}

void comparacionAssembler(tArbol *pa, char* comparador){
  struct_assembler instruccion;
  int registro = buscar_registro_en_ts((*pa)->prtIzq->valor);
  if(!strcmp(tabla_simbolos[registro].tipo,"INT")){
    strcpy(instruccion.operacion, "FILD");
  } else if (!strcmp(tabla_simbolos[registro].tipo,"FLOAT")){
    strcpy(instruccion.operacion, "FLD");
  } else{
    /*if((*pa)->prtIzq->valor[0] == '@'){
      if (((*pa)->prtIzq->info.entero != 0)){
      strcpy(instruccion.operacion, "FILD");
      strcpy(instruccion.reg1, (*pa)->prtIzq->valor);    
      }else{
      strcpy(instruccion.operacion, "FLD");
      strcpy(instruccion.reg1, (*pa)->prtIzq->valor);
      }
    } else{
      sprintf(instruccion.reg1,"_%s", (*pa)->prtIzq->valor);
    }*/
    // como proceso un string ?????? quizas lo mejor seria no procesarlo para comparaciones
  }

  sprintf(instruccion.reg1,"%s", (*pa)->prtIzq->valor);
  strcpy(instruccion.reg2,"");
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;
  
  strcpy(instruccion.operacion, "FCOMP");

  //registro = buscar_registro_en_ts((*pa)->prtDer->valor);

  /*if (!strcmp(tabla_simbolos[registro].tipo,"INT")){
    sprintf(instruccion.reg1, "%d", (*pa)->prtDer->info.entero);
  } else if ( ((*pa)->prtDer->info.flotante != 0)){
    sprintf(instruccion.reg1, "%f", (*pa)->prtDer->info.flotante);
  } else{
    if((*pa)->prtIzq->valor[0] == '@'){
      if (((*pa)->prtIzq->info.entero != 0)){
      strcpy(instruccion.reg1, (*pa)->prtDer->valor);    
      }else{
      strcpy(instruccion.reg1, (*pa)->prtDer->valor);
      }
    } else{
      sprintf(instruccion.reg1,"_%s", (*pa)->prtDer->valor);
    }
  }*/
  sprintf(instruccion.reg1,"%s", (*pa)->prtDer->valor);
       
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;
  strcpy(instruccion.operacion, "FSTSW");
  strcpy(instruccion.reg1, "AX");
  strcpy(instruccion.reg2,"");
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;
  strcpy(instruccion.operacion, "SAHF");
  strcpy(instruccion.reg1, "");
  strcpy(instruccion.reg2,"");
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;
  strcpy(instruccion.operacion, "FFREE");
  strcpy(instruccion.reg1, "");
  strcpy(instruccion.reg2,"");
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;



  if(!strcmp(comparador, ">")){
    strcpy(instruccion.operacion, "JLE");
  } else if(!strcmp(comparador, "<")){
    strcpy(instruccion.operacion, "JGE");
  } else if(!strcmp(comparador, "<=")){
    strcpy(instruccion.operacion, "JG");
  } else if(!strcmp(comparador, ">=")){
    strcpy(instruccion.operacion, "JL");
  } else if(!strcmp(comparador, "!=")){
    strcpy(instruccion.operacion, "JE");
  } else if(!strcmp(comparador, "==")){
    strcpy(instruccion.operacion, "JNE");
  }

  strcpy(instruccion.reg1, "");
  strcpy(instruccion.reg2, "");
  poner_en_pila_struct_assembler(&pilaAssembler, vector_auxs_assembler_cant);
  
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;
  
}

void asignacionAssembler(tArbol *pa){
  struct_assembler instruccion;

  strcpy(instruccion.operacion, "MOV");
  strcpy(instruccion.reg1, "R1");
  /*
  if ( ((*pa)->prtDer->info.entero != 0))
    sprintf(instruccion.reg2,"%d", (*pa)->prtDer->info.entero);
  else if ( ((*pa)->prtDer->info.flotante != 0))
    sprintf(instruccion.reg2,"%f", (*pa)->prtDer->info.flotante);
  else{
    if((*pa)->prtDer->valor[0] == '@'){
      strcpy(instruccion.reg2, (*pa)->prtDer->valor);
    } else {
      sprintf(instruccion.reg2,"_%s", (*pa)->prtDer->valor);
    }
  }*/
   sprintf(instruccion.reg1,"%s", (*pa)->prtDer->valor);

  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;

  strcpy(instruccion.operacion, "MOV");
  /*if ( ((*pa)->prtIzq->info.entero != 0)){
    sprintf(instruccion.reg1,"%d", (*pa)->prtIzq->info.entero);
  } else if ( ((*pa)->prtIzq->info.flotante != 0)) {
    sprintf(instruccion.reg1,"%f", (*pa)->prtIzq->info.flotante);
  } else {
    sprintf(instruccion.reg1,"_%s", (*pa)->prtIzq->valor);
  }*/
  sprintf(instruccion.reg1,"%s", (*pa)->prtIzq->valor);
  strcpy(instruccion.reg2, "R1");
  vector_auxs_assembler[vector_auxs_assembler_cant] = instruccion;
  vector_auxs_assembler_cant++;
}

void cerrarArchivoAssembler(FILE* arch){
  fclose(arch);
}

/* ************** PILA ASSEMBLER ********************/
void crear_pila_struct_assembler(t_pila_struct_assembler *pp){
  printf("Creando pila... \n");
  pp->tope = TOPE_PILA_struct_assembler_VACIA;
}

int poner_en_pila_struct_assembler(t_pila_struct_assembler *pp, int pi){
  if(pp->tope == TAM_PILA_struct_assembler - 1){
    printf("Pila llena\n");
    return -1;
  }
  pp->tope++;
  pp->vec[pp->tope]=pi;
  return 1;
}

int sacar_de_pila_struct_assembler(t_pila_struct_assembler *pp){
  if( pp->tope == -1){
    printf("Pila vacia\n");
    return -1;
  }
  int result;
  result = pp->vec[pp->tope];
  pp->tope--;
  return result;
}

int pila_vacia_struct_assembler(const t_pila_struct_assembler *pp){
  return pp->tope == TOPE_PILA_struct_assembler_VACIA;
}

