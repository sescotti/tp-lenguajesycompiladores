%{
#include <stdio.h>
#include <stdlib.h>
#include <String.h>
#include "y.tab.h"
#define STACK_MAX 100
#define ERROR -1
int yystopparser=0;
FILE  *yyin;
FILE* pf_asm;

typedef struct s_nodo {
    int valor;
    struct s_nodo *sig;
} t_nodo;

typedef t_nodo* t_pila;
t_pila stack;

typedef struct{
        int posicion;
        char nombre[30];
        char tipo[20];
        char valor[100];
        int longitud;
        } TS_reg;
		
 TS_reg tabla_simb[100];
FILE* pf_intermedio;
int yylval;

char* operador;

char listaDeTipos[][100]={"."};
char listaDeIDs[][100]={"."};

char _listaDeTipos[][100]={"."};
char _listaDeIDs[][100]={"."};

int _cantidadTipos=0;              
int _cantidadIDs=0;     
char* yytext;

int numberLine;


int grabar_archivo();
void agregarTipo(char * );
void agregarIDs(char * );
int busca_en_TS(char*);
void resolverTipos();

int IAtributo;
int IFactor;
int ITermino;
int IExpresion;
int IId;

typedef struct{
        char valor1[100];
        int valor2;
        int valor3;
} Tipo_Terceto;
 
Tipo_Terceto Tercetos[100];
int numTerceto=0;

/** inserta un entero en la pila */
void insertar_pila (t_pila*, int);
/** obtiene un entero de la pila */
int sacar_pila(t_pila*);
/** crea una estructura de pila */
void crear_pila(t_pila*);
/** destruye pila */
void destruir_pila(t_pila*);

int getCodigo(char* operador);
void getOperador(int codigo, char* operador);

void printfTabla(TS_reg);
%}

%token PROGRAM
%token VAR ENDVAR
%token BEGINP ENDP
%token DEF_TIPO
%token ID
%token CORCH_A CORCH_C
%token COMA
%token REAL INTEGER STRING

%token CONST_INT
%token CONST_REAL
%token CONST_STR
%token IF THEN ELSE ENDIF
%token FOR TO DO ENDFOR
%token WHILE ENDWHILE
%token REPEAT UNTIL
%token OP_LOG
%token OP_NOT
%token OP_COMPARACION
%right OP_AS
%left OP_SURES
%left OP_MULTDIV
%token P_A P_C
%token C_A C_C
%token LONG
%token IN
%token WRITE
%token READ
%token CONCAT_STRING
%token PUNTO_COMA
%token TAKE

%%

programa: 				{ printf("Inicio COMPILADOR\n"); } 
						PROGRAM 
						seccion_declaracion 
						seccion_sentencias 
						{ printf("Compilacion Exitosa! \n");};


seccion_declaracion: 	{ printf("Inicio DECLARACIONES\n"); }

						VAR 
						declaraciones 
						ENDVAR 

						{ printf("Fin de DECLARACIONES\n"); };

declaraciones: 			declaracion | 
						declaraciones declaracion;

declaracion : 			{ printf("Declaracion listado\n"); }
						CORCH_A lista_tipos CORCH_C DEF_TIPO CORCH_A lista_var CORCH_C
						{ resolverTipos(); };
				
lista_tipos : 			tipo_var | lista_tipos COMA tipo_var;

tipo_var : 				REAL 	{ agregarTipo(yytext); } | 	
						INTEGER { agregarTipo(yytext); } | 	
						STRING 	{ agregarTipo(yytext); } ;

lista_var : 			ID {agregarIDs(yytext); printfTabla(tabla_simb[$1]); }
						| 
						lista_var COMA  ID  {agregarIDs(yytext); printfTabla(tabla_simb[$3]); } ;

seccion_sentencias: 	{ printf("Inicio de Sentencias \n"); }
						
						BEGINP 
						sentencias
						ENDP;

sentencias: 			sentencia | sentencias sentencia;

sentencia : 			asignacion | decision | ciclo | iteracion | write | read | funcion_take;
						
						
write: 					{ printf ("WRITE\n");}
						WRITE atributo
						{ printf ("FIN_WRITE\n");};

read: 					{ printf ("READ\n");}
						READ ID
						{ printf ("FIN_READ\n");}

funcion_take: 			{ printf("TAKE "); }
						TAKE P_A 
							operador 
						PUNTO_COMA 
							CONST_INT
							{printf("%s",yytext);}
						PUNTO_COMA 
							lista_expresiones 
						P_C
						{ printf("FIN_TAKE\n"); }
						;						

asignacion: 			ID { IId =  CrearTerceto(tabla_simb[$1].nombre,0,0); } 
						OP_AS 
						expresion 
						{ IAtributo =  CrearTerceto(":=",IId, IExpresion); }
						;
						
decision:				{ printf("IF: "); }
						IF condicion THEN 
						{printf("\n");}
						sentencias
						{printf("\n");}
						cuerpo_decision;

cuerpo_decision: 		{printf("ELSE \n"); }
						ELSE  
						sentencias 
						ENDIF 
						{printf("\n"); }
						|
						ENDIF
						{printf("\n"); }


ciclo: 					{printf("WHILE "); }
						WHILE condicion DO 
						{printf("DO \n");}
						sentencias
						ENDWHILE
						{ printf("\n"); }; 

iteracion: 				{printf("FOR:"); }
						FOR iterador DO 
						{printf("\n");}
						sentencias 
						ENDFOR
						{ printf("\n"); }
						;

condicion: 				comparacion
						|
						condicion 
						OP_LOG { printf(" %s ",yytext ); }
						comparacion 						
						| 
						{ printf(" NOT "); }
						OP_NOT comparacion;

comparacion:  			expresion 
						OP_COMPARACION { printf(" %s ",yytext ); }
						comparativo;

comparativo: 			expresion | lista_expresiones;

iterador: 				ID IN lista_expresiones;
						
lista_expresiones: 		CORCH_A {printf("[");}
						contenido_l_expr ; 

contenido_l_expr: 		CORCH_C {printf("]");}
						| 
						expresiones CORCH_C {printf("]");};
						
expresiones: 			expresion | expresiones COMA {printf(",");} expresion ;

expresion: 				termino {IExpresion = ITermino;}
						| 
						expresion 
						OP_SURES {
							insertar_pila(&stack, getCodigo(yytext));
						} 
						termino 
						{					
							getOperador(sacar_pila(&stack), operador);
							IExpresion = CrearTerceto(operador, IExpresion,ITermino);
						}
						;

termino: 				factor {ITermino = IFactor;}
						| 
						termino 
						OP_MULTDIV  { insertar_pila(&stack, getCodigo(yytext));	} 
						factor
						{
							getOperador(sacar_pila(&stack), operador);
							ITermino = CrearTerceto(operador, ITermino,IFactor);
						}
						;

factor: 				P_A { insertar_pila(&stack, ITermino); insertar_pila(&stack, IExpresion);} 
						expresion  { IFactor = IExpresion;}
						P_C { IExpresion =sacar_pila(&stack) ; ITermino =sacar_pila(&stack) ;} 						
						| 
						atributo { IFactor = IAtributo;};
						
atributo: 				constante  { IAtributo =  CrearTerceto(tabla_simb[$1].nombre,0,0); }
						| 
						ID 	{ IAtributo = CrearTerceto(tabla_simb[$1].nombre,0,0); };

constante: 				CONST_INT | CONST_REAL | final_string;

final_string:			CONST_STR | CONST_STR CONCAT_STRING CONST_STR ;

operador: 				OP_SURES 
						|
						OP_MULTDIV 
						;

%%
int main(int argc,char *argv[]) {
  operador = (char*)malloc(sizeof(char));
  if ((yyin = fopen(argv[1], "rt")) == NULL) {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else {
	yyparse();
  }

  grabar_archivo(); 

  fclose(yyin);
  return 0;
}

int yyerror(char const *line)
{
	printf("Syntax Error en linea %d\n", numberLine);   
	exit (1);
}
/**********************TIPO y IDS***************************/
void agregarTipo(char * tipo){
	strcpy(_listaDeTipos[_cantidadTipos++],tipo);
}

void agregarIDs(char * id){
	strcpy(_listaDeIDs[_cantidadIDs++],id);
}

void resolverTipos() {

	int max = _cantidadTipos > _cantidadIDs ? _cantidadIDs : _cantidadTipos;
	int i;
	for (i=0; i<max; i++){

		char* tipo = _listaDeTipos[i];
		char* id = _listaDeIDs[i];
		int posicion = busca_en_TS(id);
		strcpy(tabla_simb[posicion].tipo, tipo);

		printf("[tipo:%s][id:%s][posicion_en_ts:%d]\n",tipo,id,posicion);
	}

	_cantidadTipos	=	0;
	_cantidadIDs 	=	0;
}

int CrearTerceto( char * val1, int val2, int val3)
{
Tipo_Terceto nuevo;
strcpy(nuevo.valor1, val1);
nuevo.valor2 = val2;
nuevo.valor3 = val3;
Tercetos[numTerceto] = nuevo;

printf ("Se crea terceto %d con valores: %s %d %d \n", numTerceto, val1, val2, val3);
numTerceto++;
return (numTerceto-1);
}

/******************************************************/


/*******************Escribir arhivo**********************/





void printfTabla(TS_reg linea_tabla)
{
	printf("pos:%d nom:%s tipo:%s val:%s long:%d \n",linea_tabla.posicion,linea_tabla.nombre,linea_tabla.tipo,linea_tabla.valor,linea_tabla.longitud);
}

int grabar_archivo()
{
    int i;
    char* TS_file = "intermedia.txt";
    
    if((pf_intermedio = fopen(TS_file, "w")) == NULL)
    {
              printf("Error al grabar el archivo de intermedio \n");
              exit(1);
    }
    
    for(i = 0; i < numTerceto; i++)
    {
          fprintf(pf_intermedio,"(%s,%d,%d)\n", Tercetos[i].valor1, Tercetos[i].valor2,Tercetos[i].valor3);
    }    
    fclose(pf_intermedio);
}

///////////////////////////////// PILA OPERADOR ///////////////////////////////////////////////

/** inserta un entero en la pila */
void insertar_pila (t_pila *p, int valor) {
    // creo nodo
    t_nodo *nodo = (t_nodo*) malloc (sizeof(t_nodo));
    // asigno valor
    nodo->valor = valor;
    // apunto al elemento siguiente
    nodo->sig = *p;
    // apunto al tope de la pila
    *p = nodo;
}

/** obtiene un entero de la pila */
int sacar_pila(t_pila *p) {
    int valor = ERROR;
    t_nodo *aux;
    if (*p != NULL) {
       aux = *p;
       valor = aux->valor;
       *p = aux->sig;
       free(aux);
    }
    return valor;
}

/** crea una estructura de pila */
void crear_pila(t_pila *p) {
    *p = NULL;
}

/** destruye pila */
void destruir_pila(t_pila *p) {
    while ( ERROR != sacar_pila(p));
}

int getCodigo(char* operador){

	if(operador[0] == '*'){
		return 1;
	} else if (operador[0] == '/'){
		return 2;
	} else if(operador[0] == '+'){
		return 3;
	} else if(operador[0] == '-'){
		return 4;
	} else {
		return 0;
	}

}

void getOperador(int codigo, char* operador){
	if(codigo == 1){
		strcpy(operador,"*");
	} else if(codigo == 2){
		strcpy(operador,"/");
	} else if(codigo == 3){
		strcpy(operador,"+");
	} else if(codigo == 4){
		strcpy(operador,"-");
	}
}