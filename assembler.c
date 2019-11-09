#include <stdio.h>
#include <stdlib.h>

  typedef struct {
    char operacion[100];
    char reg1[100];
    char reg2[100];
  } ASM;

  ASM vectorASM[200];
  int vectorASM_IDX = 0;

FILE* abrirArchivoAssembler();
void inicializarArchivoAssembler(FILE* archivoAssembler);
void generarAssembler(tArbol *pa, FILE* arch);
void operacionAssembler(tArbol *pa, char* operacion);
void asignacionAssembler(tArbol *pa);
void comparacionAssembler(tArbol *pa, char* comparador);
void cerrarArchivoAssembler(FILE* arch);
void cerrarArchivoAssembler(FILE* archivoAssembler);

/**PILA ASM**/
void crear_pila_asm(t_pila_asm *pp);
int poner_en_pila_asm(t_pila_asm *pp, int pi);
int sacar_de_pila_asm(t_pila_asm *pp);
int pila_vacia_asm(const t_pila_asm *pp);

FILE* abrirArchivoAssembler(){
  FILE* arch = fopen("assembler.txt", "w+");
  if(!arch){
    printf("No se pudo crear el archivo assembler.txt\n");
    return NULL;
  }

  return arch;
}

FILE* abrirArchivoAssembler(){
  FILE* arch = fopen("assembler.txt", "w+");
  if(!arch){
    printf("No se pudo crear el archivo assembler.txt\n");
    return NULL;
  }

  return arch;
}

void inicializarArchivoAssembler(FILE* arch , tabla_simbolos_reg tabla_simbolo[50]){
  int i = 0;
  int j = 0;
  //principio assembler y creacion de variables
  fprintf(arch, "include macros2.asm\n");
  fprintf(arch, "include number.asm\n");
  fprintf(arch, ".MODEL LARGE \n");
  fprintf(arch, ".386\n");
  fprintf(arch, ".STACK 200h \n");
  fprintf(arch, ".DATA \n");
  for(i=0; i < indice_tabla; i++){
     fprintf(arch, "%-30s\t\t\t%d\n",tabla_simbolo[i].nombre, tabla_simbolo[i].tipo);
    
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

  /* nose que hace este for
  for(i=0; i < vectorASM_IDX; i++){
    if(strcmp(vectorASM[i].reg2, "") != 0){
      fprintf(arch, "%s %s, %s\n", vectorASM[i].operacion, vectorASM[i].reg1, vectorASM[i].reg2);
    } else {
      if(strcmp(vectorASM[i].reg1, "") != 0){
      fprintf(arch, "%s %s\n", vectorASM[i].operacion, vectorASM[i].reg1);
      } else {
      fprintf(arch, "%s\n", vectorASM[i].operacion);
      }
    }
  }*/


  fprintf(arch, "\t mov AX, 4C00h \t ; Genera la interrupcion 21h\n");
  fprintf(arch, "\t int 21h \t ; Genera la interrupcion 21h\n");
  fprintf(arch, "END MAIN\n");
  fclose(arch);
}

void generarAssembler(tArbol *pa, FILE* arch){

  ASM instruccion;
  char aux[10];

  if(!*pa)
    return;
  

  if((*pa)->der != NULL || (*pa)->izq != NULL){ 
    if(!strcmp((*pa)->info.cadena, "REPEAT")){
      strcpy(instruccion.operacion, "repeat");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");
      poner_en_pila_asm(&pilaAssembler, vectorASM_IDX);
      vectorASM[vectorASM_IDX] = instruccion;
      vectorASM_IDX++;

      repeatFlag = 1;
    } else if(!strcmp((*pa)->info.cadena, "IF")){
      ifFlag = 1;
    }
  }

  generarAssembler(&(*pa)->izq, arch);
  
  if((*pa)->der != NULL || (*pa)->izq != NULL){ 
    if(!strcmp((*pa)->info.cadena, "ELSE")){
      strcpy(instruccion.operacion, "JMP");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");
      
      poner_en_pila_asm(&pilaAssembler, vectorASM_IDX);
      
      vectorASM[vectorASM_IDX] = instruccion;
      vectorASM_IDX++;

      strcpy(instruccion.operacion, "else:");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");

      vectorASM[vectorASM_IDX] = instruccion;
      vectorASM_IDX++;

      poner_en_pila_asm(&pilaElseProcesados, 1);
    }
  }

  generarAssembler(&(*pa)->der, arch);

  if((*pa)->der != NULL || (*pa)->izq != NULL){ 
    if(!strcmp((*pa)->info.cadena, "+")){
      operacionAssembler(&(*pa), "FADD");
    } else if(!strcmp((*pa)->info.cadena, "-")){
      operacionAssembler(&(*pa), "FSUB");
    } else if(!strcmp((*pa)->info.cadena, "*")){
      operacionAssembler(&(*pa), "FMUL");
    } else if(!strcmp((*pa)->info.cadena, "/")){
      operacionAssembler(&(*pa), "FDIV");
    } else if(!strcmp((*pa)->info.cadena, ":=")){
      asignacionAssembler(&(*pa));
    } else if(!strcmp((*pa)->info.cadena, ">")){
      comparacionAssembler(&(*pa), ">");
    } else if(!strcmp((*pa)->info.cadena, ">=")){
      comparacionAssembler(&(*pa), ">=");
    } else if(!strcmp((*pa)->info.cadena, "<")){
      comparacionAssembler(&(*pa), "<");
    } else if(!strcmp((*pa)->info.cadena, "<=")){
      comparacionAssembler(&(*pa), "<=");
    } else if(!strcmp((*pa)->info.cadena, "==")){
      comparacionAssembler(&(*pa), "==");
    } else if(!strcmp((*pa)->info.cadena, "!=")){
      comparacionAssembler(&(*pa), "!=");
    } else if(!strcmp((*pa)->info.cadena, "IF")){
      int pos_condicion;
      int tipo_condicion;
      int jump_else;
      
      strcpy(instruccion.operacion, "endif:");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");
      
      vectorASM[vectorASM_IDX] = instruccion;
      vectorASM_IDX++;

      //Si la pila de else procesados está vacía, significa que es un if sin else
      if(!pila_vacia_asm(&pilaElseProcesados)){
        if(pila_vacia(&pilaCondicionIFAssembler)){
          jump_else = sacar_de_pila_asm(&pilaAssembler);
          strcpy(vectorASM[jump_else].reg1, "endif");
          pos_condicion = sacar_de_pila_asm(&pilaAssembler);
          strcpy(vectorASM[pos_condicion].reg1, "else");
        } else {
          tipo_condicion = sacar_de_pila_asm(&pilaCondicionIFAssembler);
          if(tipo_condicion == AND){
            pos_condicion = sacar_de_pila_asm(&pilaAssembler);
            strcpy(vectorASM[pos_condicion].reg1, "else");
            pos_condicion = sacar_de_pila_asm(&pilaAssembler);
            strcpy(vectorASM[pos_condicion].reg1, "else");
          }
        }
        sacar_de_pila_asm(&pilaElseProcesados);
      } else {
        if(pila_vacia_asm(&pilaCondicionIFAssembler)){
          pos_condicion = sacar_de_pila_asm(&pilaAssembler);
          strcpy(vectorASM[pos_condicion].reg1, "endif");
        } else {
          tipo_condicion = sacar_de_pila_asm(&pilaCondicionIFAssembler);
          if(tipo_condicion == AND){
            pos_condicion = sacar_de_pila_asm(&pilaAssembler);
            strcpy(vectorASM[pos_condicion].reg1, "endif");
            pos_condicion = sacar_de_pila_asm(&pilaAssembler);
            strcpy(vectorASM[pos_condicion].reg1, "endif");
          }
        }
      }
      
      
      
    } else if(!strcmp((*pa)->info.cadena, "REPEAT")){
      int pos_condicion;
      int pos_ini_repeat;
      int tipo_condicion;
      
      if(pila_vacia_asm(&pilaCondicionREPEATAssembler)){
        pos_condicion = sacar_de_pila_asm(&pilaAssembler);
        strcpy(vectorASM[pos_condicion].reg1, "endrepeat");
      } else {
        tipo_condicion = sacar_de_pila_asm(&pilaCondicionREPEATAssembler);
        if(tipo_condicion == AND){
          pos_condicion = sacar_de_pila_asm(&pilaAssembler);
          strcpy(vectorASM[pos_condicion].reg1, "endrepeat");
          pos_condicion = sacar_de_pila_asm(&pilaAssembler);
          strcpy(vectorASM[pos_condicion].reg1, "endrepeat");
        }
      }

      pos_ini_repeat = sacar_de_pila_asm(&pilaAssembler);
      
      strcpy(instruccion.operacion, "JMP");
      strcpy(instruccion.reg1, vectorASM[pos_ini_repeat].operacion);
      strcpy(instruccion.reg2, "");
      
      vectorASM[vectorASM_IDX] = instruccion;
      vectorASM_IDX++;
      
      strcpy(instruccion.operacion, "endrepeat:");
      strcpy(instruccion.reg1, "");
      strcpy(instruccion.reg2, "");
      
      vectorASM[vectorASM_IDX] = instruccion;
      vectorASM_IDX++;
      
    } else if(!strcmp((*pa)->info.cadena, "AND")){
      if(repeatFlag == 1){
        poner_en_pila_asm(&pilaCondicionREPEATAssembler, AND);
        repeatFlag = 0;
      } else if (ifFlag == 1){
        poner_en_pila_asm(&pilaCondicionIFAssembler, AND);
        ifFlag = 0;
      }
      
    } else if(!strcmp((*pa)->info.cadena, "OR")){
      if(repeatFlag == 1){
        poner_en_pila_asm(&pilaCondicionREPEATAssembler, OR);
        repeatFlag = 0;
      } else if (ifFlag == 1){
        poner_en_pila_asm(&pilaCondicionIFAssembler, OR);
        ifFlag = 0;
      }
    }
  }
}


void operacionAssembler(tArbol *pa, char* operacion){
  
  char aux[10];
  char aux2[10];
  ASM instruccion;

  if( ((*pa)->izq->info.tipoDato == Integer)||((*pa)->izq->info.tipoDato == CteInt)){
    strcpy(instruccion.operacion,"FILD");
  } else if (((*pa)->izq->info.tipoDato == Float)||((*pa)->izq->info.tipoDato == CteFloat)){
    strcpy(instruccion.operacion,"FLD");
  } else{
    strcpy(instruccion.operacion,"STRING");
  }
  
  
  if( ((*pa)->izq->info.entero != 0)){    
    sprintf(instruccion.reg1,"%d", (*pa)->izq->info.entero);
  } else if ( ((*pa)->izq->info.flotante != 0)){    
    sprintf(instruccion.reg1,"%f", (*pa)->izq->info.flotante);
  } else {
    if((*pa)->izq->info.cadena[0] == '@'){
      strcpy(instruccion.reg1, (*pa)->izq->info.cadena);
    } else {
      sprintf(instruccion.reg1,"_%s", (*pa)->izq->info.cadena);
    } 
  }
  
  strcpy(instruccion.reg2,"");
  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;

  if( ((*pa)->der->info.tipoDato == Integer)||((*pa)->der->info.tipoDato == CteInt)){
    strcpy(instruccion.operacion,"FILD");
  } else if(((*pa)->der->info.tipoDato == Float)||((*pa)->der->info.tipoDato == CteFloat)){
    strcpy(instruccion.operacion,"FLD");
  } else{
    strcpy(instruccion.operacion,"STRING");
  }

  if ( ((*pa)->der->info.entero != 0)){
    sprintf(instruccion.reg1, "%d", (*pa)->der->info.entero);
  } else if ( ((*pa)->der->info.flotante != 0)) {
    sprintf(instruccion.reg1, "%f", (*pa)->der->info.flotante);
  } else {
    if((*pa)->izq->info.cadena[0] == '@'){
      strcpy(instruccion.reg1, (*pa)->der->info.cadena);
    } else {
      sprintf(instruccion.reg1,"_%s", (*pa)->der->info.cadena);
    } 
  }

  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;

  strcpy(instruccion.operacion, operacion);
  strcpy(instruccion.reg1,"");
  strcpy(instruccion.reg2,"");
    vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;

  contAssembler++;
  strcpy(aux, "@aux");
  sprintf(aux2, "%d", contAssembler);
  strcat(aux, aux2);
  insertarEnTabla(aux,indice_tabla,(*pa)->info.tipoDato);

  strcpy(instruccion.operacion, "FSTP");
  strcpy(instruccion.reg2,"");
  strcpy(instruccion.reg1, aux);
  strcpy(auxAssembler, aux);
  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;

    strcpy(instruccion.operacion, "FFREE");
    strcpy(instruccion.reg1,"");
  strcpy(instruccion.reg2,"");
  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;
    
    strcpy(instruccion.operacion, "");  
  (*pa)->der = NULL;
  (*pa)->izq = NULL;
  strcpy((*pa)->info.cadena,auxAssembler);
  (*pa)->info.entero = 0;
  (*pa)->info.flotante = 0; 
}

void comparacionAssembler(tArbol *pa, char* comparador){
  ASM instruccion;

  if( ((*pa)->izq->info.entero != 0)){
    strcpy(instruccion.operacion, "FILD");
    sprintf(instruccion.reg1,"%d", (*pa)->izq->info.entero);
  } else if ( ((*pa)->izq->info.flotante != 0)){
    strcpy(instruccion.operacion, "FLD");
    sprintf(instruccion.reg1,"%f", (*pa)->izq->info.flotante);
  } else{
    if((*pa)->izq->info.cadena[0] == '@'){
      if (((*pa)->izq->info.entero != 0)){
      strcpy(instruccion.operacion, "FILD");
      strcpy(instruccion.reg1, (*pa)->izq->info.cadena);    
      }else{
      strcpy(instruccion.operacion, "FLD");
      strcpy(instruccion.reg1, (*pa)->izq->info.cadena);
      }
    } else{
      sprintf(instruccion.reg1,"_%s", (*pa)->izq->info.cadena);
    }
  }
    strcpy(instruccion.reg2,"");
  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;
  
  strcpy(instruccion.operacion, "FCOMP");
  if ( ((*pa)->der->info.entero != 0)){
    sprintf(instruccion.reg1, "%d", (*pa)->der->info.entero);
  } else if ( ((*pa)->der->info.flotante != 0)){
    sprintf(instruccion.reg1, "%f", (*pa)->der->info.flotante);
  } else{
    if((*pa)->izq->info.cadena[0] == '@'){
      if (((*pa)->izq->info.entero != 0)){
      strcpy(instruccion.reg1, (*pa)->der->info.cadena);    
      }else{
      strcpy(instruccion.reg1, (*pa)->der->info.cadena);
      }
    } else{
      sprintf(instruccion.reg1,"_%s", (*pa)->der->info.cadena);
    }
  }
       
  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;
  strcpy(instruccion.operacion, "FSTSW");
  strcpy(instruccion.reg1, "AX");
  strcpy(instruccion.reg2,"");
    vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;
    strcpy(instruccion.operacion, "SAHF");
  strcpy(instruccion.reg1, "");
  strcpy(instruccion.reg2,"");
    vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;
  strcpy(instruccion.operacion, "FFREE");
  strcpy(instruccion.reg1, "");
  strcpy(instruccion.reg2,"");
    vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;



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
  poner_en_pila_asm(&pilaAssembler, vectorASM_IDX);
  
  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;
  
}

void asignacionAssembler(tArbol *pa){
  ASM instruccion;

  strcpy(instruccion.operacion, "MOV");
  strcpy(instruccion.reg1, "R1");
  if ( ((*pa)->der->info.entero != 0))
    sprintf(instruccion.reg2,"%d", (*pa)->der->info.entero);
  else if ( ((*pa)->der->info.flotante != 0))
    sprintf(instruccion.reg2,"%f", (*pa)->der->info.flotante);
  else{
    if((*pa)->der->info.cadena[0] == '@'){
      strcpy(instruccion.reg2, (*pa)->der->info.cadena);
    } else {
      sprintf(instruccion.reg2,"_%s", (*pa)->der->info.cadena);
    }
  }

  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;

  strcpy(instruccion.operacion, "MOV");
  if ( ((*pa)->izq->info.entero != 0)){
    sprintf(instruccion.reg1,"%d", (*pa)->izq->info.entero);
  } else if ( ((*pa)->izq->info.flotante != 0)) {
    sprintf(instruccion.reg1,"%f", (*pa)->izq->info.flotante);
  } else {
    sprintf(instruccion.reg1,"_%s", (*pa)->izq->info.cadena);
  }
  strcpy(instruccion.reg2, "R1");

  vectorASM[vectorASM_IDX] = instruccion;
  vectorASM_IDX++;
}

void cerrarArchivoAssembler(FILE* arch){
  fclose(arch);
}

/* ************** PILA ASSEMBLER ********************/
void crear_pila_asm(t_pila_asm *pp){
  printf("Creando pila... \n");
  pp->tope = TOPE_PILA_ASM_VACIA;
}

int poner_en_pila_asm(t_pila_asm *pp, int pi){
  if(pp->tope == TAM_PILA_ASM - 1){
    printf("Pila llena\n");
    return -1;
  }
  pp->tope++;
  pp->vec[pp->tope]=pi;
  return 1;
}

int sacar_de_pila_asm(t_pila_asm *pp){
  if( pp->tope == -1){
    printf("Pila vacia\n");
    return -1;
  }
  int result;
  result = pp->vec[pp->tope];
  pp->tope--;
  return result;
}

int pila_vacia_asm(const t_pila_asm *pp){
  return pp->tope == TOPE_PILA_ASM_VACIA;
}

