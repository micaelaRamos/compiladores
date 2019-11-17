typedef struct nodoArbol {
  char valor[255];
  struct nodoArbol *ptrIzq;
  struct nodoArbol *prtDer;
  char *tipoNodo;
} NodoArbol;

typedef NodoArbol *ptrNodoArbol; /* Puntero a NodoArbol* */
