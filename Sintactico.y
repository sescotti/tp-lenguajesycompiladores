%{
#include <stdio.h>
#include <stdlib.h>
#include <String.h>
#include "y.tab.h"
#define STACK_MAX 100
#define ERROR -1
int yystopparser=0;
FILE  *yyin;

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
FILE* pf_asm;
int yylval;

char* operador;
char* get_nombre_cte_string_asm(char*);

char _listaDeTipos[][100]={"."};
char _listaDeIDs[][100]={"."};

int _cantidadTipos=0;              
int _cantidadIDs=0;     
char* yytext;

int numberLine;

//grabar archivo de Tercetos
int grabar_archivo();


//grabar archivo assembler
int grabar_archivo_asm();
extern int cant_entradas;

void agregarTipo(char * );
void agregarIDs(char * );
int busca_en_TS(char*);
int ValidarIDDeclarado(TS_reg );
void resolverTipos();
int IAtributo;
int IFactor;
int ITermino;
int IExpresion;
int IAsignacion;
int IExpresiones;
int IIterador;
int IContenidoExp;
int IListaExpresiones;
int IComparacion;
int IComparativo;
int ICondicion;
int IDecision;
int ICuerpoDecision;
int ICiclo;
int ISentencias;
int ISentencia;

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

sentencias: 			sentencia {ISentencias = ISentencia;}
						| 
						sentencias sentencia {ISentencias = ISentencia;};

sentencia : 			asignacion {ISentencia = IAsignacion;}
						| decision {ISentencia = IDecision;}
						| ciclo {ISentencia = ICiclo;}
						|  write {ISentencia = 0;}
						| read {ISentencia = 0;}
						| funcion_take {ISentencia = 0;};
						
write: 					WRITE atributo

read: 					READ ID
						
funcion_take: 			TAKE P_A 
							operador 
						PUNTO_COMA 
							CONST_INT
							{printf("%s",yytext);}
						PUNTO_COMA 
							lista_expresiones 
						P_C
						{ printf("FIN_TAKE\n"); }
						;						

asignacion: 			atributo { IAsignacion = IAtributo;}
						OP_AS 
						expresion 
						{ IAsignacion =  CrearTerceto(":=",IAsignacion, IExpresion); }
						;
						
decision:				IF condicion {IDecision = ICondicion;}
						THEN 
						sentencias
						cuerpo_decision {IDecision = ICuerpoDecision;}
						;

cuerpo_decision: 		ELSE  
							{
								ICuerpoDecision = CrearTerceto ("BI",0,0);
								Tercetos[IDecision].valor3 = (ICuerpoDecision+1);			
								printf ("Se re-carga terceto %d con valores: %s %d %d \n", IDecision, Tercetos[IDecision].valor1, Tercetos[IDecision].valor2, Tercetos[IDecision].valor3);		
								}
						sentencias 
							{ 	Tercetos[ICuerpoDecision].valor2 = (ISentencias+1);			
								printf ("Se re-carga terceto %d con valores: %s %d %d \n", ICuerpoDecision, Tercetos[ICuerpoDecision].valor1, Tercetos[ICuerpoDecision].valor2, Tercetos[ICuerpoDecision].valor3);		
							}
						ENDIF
						{ICuerpoDecision= ISentencias;}						
						|
						{	Tercetos[IDecision].valor3 = (ISentencias+1);			
							printf ("Se re-carga terceto %d con valores: %s %d %d \n", IDecision, Tercetos[IDecision].valor1, Tercetos[IDecision].valor2, Tercetos[IDecision].valor3);		
						}
						ENDIF
						{ ICuerpoDecision = ISentencias;}
						

ciclo: 					{printf("WHILE "); }
						WHILE condicion DO 
							sentencias
						ENDWHILE
						{ printf("\n"); }; 

condicion: 				comparacion {ICondicion = IComparacion; }
						|
						condicion 
						OP_LOG { insertar_pila(&stack, getCodigo(yytext));}
						comparacion 				
						{getOperador(sacar_pila(&stack), operador);
						ICondicion = CrearTerceto(operador, ICondicion,IComparacion);}
						| 
						OP_NOT comparacion
						{ICondicion = CrearTerceto("NOT", IComparacion,0);};

comparacion:  			expresion  {IComparacion = IExpresion;}
						OP_COMPARACION {insertar_pila(&stack, getCodigo(yytext));}
						comparativo 
						{
							IComparacion = CrearTerceto("CMP",IComparacion,IComparativo );
							getOperador(sacar_pila(&stack), operador); 
							IComparacion = CrearTerceto(operador,IComparacion,0 );}
						;

comparativo: 			expresion {IComparativo = IExpresion;}
						| 
						lista_expresiones { IComparativo = IListaExpresiones;}
						;
					
lista_expresiones: 		CORCH_A 
						contenido_l_expr 
						{ IListaExpresiones = IContenidoExp ;}; 

contenido_l_expr: 		CORCH_C { IContenidoExp = 0; }
						| 
						expresiones CORCH_C { IContenidoExp = IExpresiones;};
						
expresiones: 			expresion {IExpresiones = IExpresion ; }
						| 
						expresiones 
						COMA 
						expresion 
						{IExpresiones = CrearTerceto (",", IExpresiones,IExpresion);}
						;

expresion: 				termino {IExpresion = ITermino;}
						| 
						expresion 
						OP_SURES {	insertar_pila(&stack, getCodigo(yytext));} 
						termino 
						{getOperador(sacar_pila(&stack), operador);IExpresion = CrearTerceto(operador, IExpresion,ITermino);}
						;

termino: 				factor {ITermino = IFactor;}
						| 
						termino 
						OP_MULTDIV  { insertar_pila(&stack, getCodigo(yytext));	} 
						factor
						{getOperador(sacar_pila(&stack), operador);ITermino = CrearTerceto(operador, ITermino,IFactor);}
						;

factor: 				P_A { insertar_pila(&stack, ITermino); insertar_pila(&stack, IExpresion);} 
						expresion  { IFactor = IExpresion;}
						P_C { IExpresion =sacar_pila(&stack) ; ITermino =sacar_pila(&stack) ;} 						
						| 
						atributo { IFactor = IAtributo;};
						
atributo: 				constante  { IAtributo =  CrearTerceto(tabla_simb[$1].nombre,0,0); }
						| 
						ID 	
						{ ValidarIDDeclarado(tabla_simb[yylval]);}
						{ IAtributo = CrearTerceto(tabla_simb[$1].nombre,0,0); };
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
  grabar_archivo_asm();
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
//Chequeamos que el tipo que le pasemos existe en los existenes, sino el id no fue declarado
int ValidarIDDeclarado(TS_reg registroTabla)
{

    int i;
	 printf("Buscando ID con %s\n",registroTabla.tipo);
      if(strcmp("ID", registroTabla.tipo) == 0)
      {
      	printf("ERROR ID %s NO DECLARADO \n",registroTabla.nombre);
      //  yyterminate();
   		exit(1);
        return -1;
      }

   	return 1;  
  
}


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

int grabar_archivo_asm()
{
     int i;
     char aux_cte[31];

     char* Asm_file = "Final.txt";
     
     if((pf_asm = fopen(Asm_file, "w")) == NULL)
     {
               printf("Error al grabar el archivo de intermedio \n");
               exit(1);
     }
     
      fprintf(pf_asm, ".MODEL	LARGE \n");
	  fprintf(pf_asm, ".386 \n");
	  fprintf(pf_asm, ".STACK 200h \n");
	  fprintf(pf_asm, ".DATA \n");

		for(i=0; i<cant_entradas; i++)
		{
			strcpy(aux_cte, get_nombre_cte_string_asm(tabla_simb[i].nombre));
			//if(!strcmp(tabla_simb[i].tipo, "CONST_REAL"))
			//{
			//	fprintf(pf_asm, "\t_%s dd %s \n", aux_cte, tabla_simb[i].valor);
			//}
			//else 
				if(!strcmp(tabla_simb[i].tipo, "string"))
			{
				//cad1 db ìprimer cadenaî,í$í, 37 dup (?)
				//_aux1 db MAXTEXTSIZE dup(?), ë$í 
				fprintf(pf_asm, "\t_%s db  %d dup (?) '$'\n", aux_cte,30 );//30 - Tabla_simb[i].longitud);
			}
			//Si descomentamos esto solo pone lo que sean variables
			else if(!strcmp(tabla_simb[i].tipo, "real") || !strcmp(tabla_simb[i].tipo, "integer")  )
			{
				fprintf(pf_asm, "\t_%s dd ? \n", aux_cte);
			}
		}

	   fprintf(pf_asm, ".CODE \n");
	   fprintf(pf_asm, "\t mov AX,@DATA \n");
	   fprintf(pf_asm, "\t mov DS,AX \n");
	 /*
		 *
		 *
		 *
		*/
	 fprintf(pf_asm, "\t mov ax, 4C00h \n");
	 fprintf(pf_asm, "\t int 21h \n");
	 fprintf(pf_asm, "\t END \n");
     
     fclose(pf_asm);
}

char* get_nombre_cte_string_asm(char* cte)
{
	/*Para quitar caracteres raros para asm*/
	char aux[31];
	int  i=0;
	
	while(*cte != '\0')
	{
		if(*cte != ' ' && *cte != '\"' && *cte != '.' && *cte != '+' && *cte != '-' && *cte != '*' && *cte != '/' && *cte != ','
			&& *cte != '&' && *cte != '|' && *cte != '!' && *cte != '(' && *cte != ')' && *cte != '[' && *cte != ']'
			&& *cte != ':' && *cte != '=' && *cte != '<' && *cte != '>' && *cte != '@' && *cte != '%' && *cte != '$')
		{
			aux[i] = *cte;
			i++;
		}
		cte++;
	}
	aux[i] = '\0';
	
	return aux;
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
	} else if (strcmp(operador,"in") == 0) {
		return 5;
	} else if (strcmp(operador,"==") == 0) {
		return 6;
	} else if (strcmp(operador,"<>") == 0) {
		return 7;
	} else if (strcmp(operador,"<") == 0) {
		return 8;
	} else if (strcmp(operador,">") == 0) {
		return 9;
	} else if (strcmp(operador,">=") == 0) {
		return 10;
	} else if (strcmp(operador,"<=") == 0) {
		return 11;
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
	} else if (codigo == 5) {
		strcpy(operador, "in");
	} else if (codigo == 6) {
		strcpy(operador, "BNE");
	} else if (codigo == 7) {
		strcpy(operador, "BEQ");
	} else if (codigo == 8) {
		strcpy(operador, "BGE");
	} else if (codigo == 9) {
		strcpy(operador, "BLE");
	} else if (codigo == 10) {
		strcpy(operador, "BLT");
	} else if (codigo == 11) {
		strcpy(operador, "BGT");
	} 
}