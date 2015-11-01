%{
#include <stdio.h>
#include <stdlib.h>
#include <String.h>
#include "y.tab.h"

int yystopparser=0;
FILE  *yyin;

 typedef struct{
        int posicion;
        char nombre[30];
        char tipo[20];
        char valor[100];
        int longitud;
        } TS_reg;
		
 TS_reg tabla_simb[100];
FILE* pf_intermedio;

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
%token OP_AS
%token OP_SURES
%token OP_MULTDIV
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

programa: 				{ printf("Inicio COMPILADOR\n");   grabar_archivo();  } 
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

constante: 				CONST_INT | CONST_REAL | final_string;

final_string:			CONST_STR | CONST_STR CONCAT_STRING CONST_STR

lista_var : 			ID {agregarIDs(yytext); } { printfTabla(tabla_simb[$1]); printfTabla(tabla_simb[$1]); }| lista_var COMA  ID  {agregarIDs(yytext); } { printf ("SINTACTICO ====>LISTA_VAR:%s %d\n ",tabla_simb[$3].nombre,$3); } ;

operador: 				{ printf("Operador\n"); }
						OP_SURES | OP_MULTDIV;

seccion_sentencias: 	{ printf("Inicio de Sentencias \n"); }
						
						BEGINP 
						sentencias
						ENDP;

sentencias: 			{ printf ("SENTENCIAS\n"); }
						sentencia | sentencias sentencia;

sentencia : 			{ printf ("SENTENCIA\n"); }
						asignacion 
					
						| decision | ciclo | iteracion | write | read | funcion_take;
						
						
write: 					{ printf ("WRITE\n");}
						WRITE atributo
						{ printf ("FIN_WRITE\n");};

read: 					{ printf ("READ\n");}
						READ ID
						{ printf ("FIN_READ\n");}

asignacion: 			{ printf("ASIGNACION\n");   } 
						ID { printf ("SINTACTICO ====>ASIGNACION:%s $1:%d $$:%d\n ",tabla_simb[$1].nombre,$1,$$); } OP_AS expresion 
						
						{ printf("FIN_ASIGNACION\n"); }

decision:				{ printf("IF\n"); }
						IF condicion THEN 
						
						sentencias
						cuerpo_decision;

cuerpo_decision: 		{ printf("ELSE\n"); }
						ELSE 
						sentencias 
						ENDIF 
						{ printf("FIN_DE_IF_CON_ELSE\n"); }
						|
						ENDIF
						{ printf("FIN_DE_IF\n"); }


ciclo: 					{ printf("CICLO\n"); }
						WHILE condicion DO 
						sentencias
						ENDWHILE
						{ printf("FIN_DE_CICLO\n"); }; 

iteracion: 				{ printf("FOR\n"); }
						FOR iterador 
						DO 
						sentencias 
						ENDFOR
						{ printf("FIN_FOR\n"); }
						;

condicion: 				{ printf("CONDICION\n"); }
						comparacion |
						condicion OP_LOG comparacion | 
						{ printf("NEGACION COMPARACION\n"); }
						OP_NOT comparacion;

comparacion:  			{ printf("COMPARACION\n"); }
						expresion OP_COMPARACION comparativo;

comparativo: 			{ printf("COMPARATIVO\n"); }
						expresion | lista_expresiones;

iterador: 				{ printf("ITERADOR\n"); }
						ID IN lista_expresiones
						;
						

lista_expresiones: 		CORCH_A contenido_l_expr ; 

contenido_l_expr: 		CORCH_C | expresiones CORCH_C ;
						
expresiones: 			expresion | expresiones COMA expresion;

expresion: 				termino | expresion OP_SURES termino ;

termino: 				factor | termino OP_MULTDIV factor;

funcion_take: 			{ printf("TAKE\n"); }
						TAKE P_A operador PUNTO_COMA 
								CONST_INT PUNTO_COMA lista_expresiones P_C
						{ printf("FIN_TAKE\n"); }
						;
						
atributo: 				constante  { printf ("SINTACTICO ====>Constante:%s\n ",tabla_simb[$1].nombre); }
						| ID 	{ printf ("SINTACTICO ====>ID:%s\n ",tabla_simb[$1].nombre); };

factor: 				P_A expresion P_C | atributo;


%%
int main(int argc,char *argv[]) {
  
  if ((yyin = fopen(argv[1], "rt")) == NULL) {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else {
	yyparse();
  }
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

	for (int i=0; i<max; i++){

		char* tipo = _listaDeTipos[i];
		char* id = _listaDeIDs[i];
		int posicion = busca_en_TS(id);
		strcpy(tabla_simb[posicion].tipo, tipo);

		printf("[tipo:%s][id:%s][posicion_en_ts:%d]\n",tipo,id,posicion);
	}

	_cantidadTipos	=	0;
	_cantidadIDs 	=	0;
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
     
     fprintf(pf_intermedio, "Codigo Intermedio \n");
     
    /*  for(i = 0; i < cant_entradas; i++)
      {
           fprintf(pf_TS,"%d \t\t\t\t %s \t\t\t", tabla_simb[i].posicion, tabla_simb[i].nombre);
           
          
            if(tabla_simb[i].tipo != NULL)
               fprintf(pf_TS,"%s \t\t\t", tabla_simb[i].tipo);
           
          
            if(tabla_simb[i].valor != NULL)
               fprintf(pf_TS,"%s \t\t\t", tabla_simb[i].valor);
           
            fprintf(pf_TS,"%d \n", tabla_simb[i].longitud);
      }*/    
     fclose(pf_intermedio);
}
