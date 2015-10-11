%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

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

declaracion : 			{ printf("Declaracion simple\n"); }
						tipo_var DEF_TIPO lista_var |				
						
						{ printf("Declaracion listado\n"); }
						CORCH_A lista_tipos CORCH_C DEF_TIPO CORCH_A lista_var CORCH_C;

lista_tipos : 			tipo_var | lista_tipos COMA tipo_var;

tipo_var : 				REAL | INTEGER | STRING;

constante: 				CONST_INT | CONST_REAL | CONST_STR;

lista_var : 			ID | lista_var COMA ID;

operador: 				{ printf("Operador\n"); }
						OP_SURES | OP_MULTDIV;

lista_constantes_ent: 	CORCH_A constantes_ent CORCH_C;

constantes_ent: 		CONST_INT | constantes_ent COMA CONST_INT;

seccion_sentencias: 	{ printf("Inicio de Sentencias\n"); }
						
						BEGINP 
						sentencias
						ENDP;

sentencias: 			{ printf ("SENTENCIAS\n"); }
						sentencia | sentencias sentencia;

sentencia : 			{ printf ("SENTENCIA\n"); }
						funcion_take | asignacion | decision | ciclo | iteracion | write | read;

write: 					{ printf ("WRITE\n");}
						WRITE atributo
						{ printf ("FIN_WRITE\n");};

read: 					{ printf ("READ\n");}
						READ ID
						{ printf ("FIN_READ\n");}

asignacion: 			{ printf("ASIGNACION\n"); }
						ID OP_AS expresion 

decision:				{ printf("IF\n"); }
						IF condicion THEN 
						sentencias 
						ELSE 
						{ printf("ELSE\n"); }
						sentencias 
						ENDIF 
						{ printf("FIN_DE_IF\n"); }
						
						|

						{ printf("IF\n"); }
						IF  condicion THEN 
						sentencias 
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
						OP_NOT comparacion | iterador;

comparacion:  			{ printf("COMPARACION\n"); }
						P_A condicion P_C |
						expresion OP_COMPARACION expresion;

iterador: 				{ printf("ITERADOR\n"); }
						ID IN lista_expresiones;

lista_expresiones: 		CORCH_A expresiones CORCH_C;

expresiones: 			expresion | expresiones COMA expresion;

expresion: 				termino | expresion OP_SURES termino ;

termino: 				factor | termino OP_MULTDIV factor;

funcion_take: 			{ printf("TAKE\n"); }
						TAKE P_A operador PUNTO_COMA 
								CONST_INT PUNTO_COMA expresiones P_C
						{ printf("FIN_TAKE\n"); }
									;
						
atributo: 				constante | ID

factor: 				P_A expresion P_C | atributo | funcion_take;


%%
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  fclose(yyin);
  return 0;
}

int yyerror(void)
{
	printf("Syntax Error\n");   
	exit (1);
}
