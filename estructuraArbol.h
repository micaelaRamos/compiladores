typedef struct nodoArbol {
  char valor[255];
  struct nodoArbol *ptrIzq;
  struct nodoArbol *prtDer;
} NodoArbol;

typedef NodoArbol *ptrNodoArbol; /* Puntero a NodoArbol* */
