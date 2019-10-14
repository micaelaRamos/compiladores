#include <stdio.h>
#include <stdlib.h>
#include "estructuraArbol.h"



/* prototipos */
ptrNodoArbol crearNodo(char valor[255], ptrNodoArbol *ptrArbolIzq, ptrNodoArbol *ptrArbolDer);
ptrNodoArbol crearHoja(char valor[255]);
void postOrden(ptrNodoArbol ptrArbol);
void inicializarArbol();

/*Variables*/
ptrNodoArbol ptrRaiz;


/* inserta un nodo dentro del Arbol */
ptrNodoArbol crearNodo( char valor[255], ptrNodoArbol *ptrArbolIzq, ptrNodoArbol *ptrArbolDer ) {


    /*Crea el nodo que va a devolver*/
    ptrNodoArbol ptrNodo;
    ptrNodo = malloc(sizeof(NodoArbol));
    /*Asigno los parametros*/
    strcpy((ptrNodo)->valor,valor);
    printf("%s" "%s" "%s\n", "Consola: Guardando Valor ", (ptrNodo)->valor, " en el nodo");
    (ptrNodo)->ptrIzq = *ptrArbolIzq;
    (ptrNodo)->prtDer = *ptrArbolDer;

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

void inicializarArbol(){
  ptrRaiz = NULL; /* árbol inicialemnte vacío */
}
