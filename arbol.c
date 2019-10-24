#include <stdio.h>
#include <stdlib.h>
#include "estructuraArbol.h"

FILE *file;

/* prototipos */
ptrNodoArbol crearNodo(char valor[255], ptrNodoArbol ptrArbolIzq, ptrNodoArbol ptrArbolDer);
ptrNodoArbol crearHoja(char valor[255]);
void postOrden(ptrNodoArbol ptrArbol);
void inicializarArbol();


/* inserta un nodo dentro del Arbol */
ptrNodoArbol crearNodo( char valor[255], ptrNodoArbol ptrArbolIzq, ptrNodoArbol ptrArbolDer ) {


    /*Crea el nodo que va a devolver*/
    ptrNodoArbol ptrNodo;
    ptrNodo = malloc(sizeof(NodoArbol));
    /*Asigno los parametros*/
    strcpy((ptrNodo)->valor,valor);
    printf("%s" "%s" "%s\n", "Consola: Guardando Valor ", (ptrNodo)->valor, " en el nodo");
    (ptrNodo)->ptrIzq = ptrArbolIzq;
    (ptrNodo)->prtDer = ptrArbolDer;

    return ptrNodo;

}

ptrNodoArbol crearHoja(char valor[255]){
  /*Crea el nodo que va a devolver*/
  ptrNodoArbol ptrNodo;
  ptrNodo = malloc(sizeof(NodoArbol));

  /*Asigno los parametros*/
  strcpy((ptrNodo)->valor,valor);
  printf("%s" "%s" "%s\n", "Consola: Guardando Valor ", (ptrNodo)->valor, " en la hoja");
  (ptrNodo)->ptrIzq = NULL;
  (ptrNodo)->prtDer = NULL;

  return ptrNodo;
}

void postOrder(ptrNodoArbol ptrArbol)
{
 /* si el árbol no está vacío, entonces recórrelo */
  if (ptrArbol != NULL) {
    postOrder(ptrArbol->ptrIzq);
    postOrder(ptrArbol->prtDer);
    printf("\t Valor de nodo: %s\n", ptrArbol->valor);
  }
}

void inOrder(ptrNodoArbol ptrArbol)
{ 
   if (ptrArbol != NULL) {
    inOrder(ptrArbol->ptrIzq);
    fprintf(file, "%s ", ptrArbol->valor);
    printf("%s ", ptrArbol->valor);
    inOrder(ptrArbol->prtDer);
  }
}

void inicializarArbol(ptrNodoArbol arbol){
  arbol = NULL; /* árbol inicialemnte vacío */
}

void guardarArbol(NodoArbol * arbol) {
    NodoArbol* aux = arbol;
    file = fopen("intermedia.txt", "w");
    if (file == NULL)
    {
        printf("Error opening file!\n");
        exit(1);
    }

    inOrder(aux);
    fclose(file);
}
