%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
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
programa: PROGRAM {printf("Inicio COMPILADOR\n");} seccion_declaracion seccion_sentencias {printf("Compilacion Exitosa! \n");};
seccion_declaracion: {printf("Inicio DECLARACIONES\n");} VAR declaraciones ENDVAR {printf("Fin de Declaraciones\n");} ;
declaraciones: declaracion | declaraciones declaracion ;
declaracion : 	{printf("Declaracion simple\n");}tipo_var DEF_TIPO lista_var |				
				{printf("Declaracion listado\n");}CORCH_A lista_tipos CORCH_C DEF_TIPO CORCH_A lista_var CORCH_C ;
lista_tipos : tipo_var | lista_tipos COMA tipo_var;
tipo_var : REAL | INTEGER | STRING;
lista_var : ID | lista_var COMA ID;

seccion_sentencias: BEGINP{printf("Inicio de Sentencias\n");} sentencias ENDP;
sentencias: sentencia | sentencias sentencia ;
sentencia : asignacion | decision | ciclo | iteracion | ciclo_especial;
asignacion: ID OP_AS expresion {printf("ASIGNACION\n");};
decision:	IF  condicion THEN sentencias ELSE sentencias ENDIF {printf("IF con ELSE\n");} |
			IF  condicion THEN sentencias ENDIF{printf("IF\n");} ;
ciclo: WHILE { printf("CICLO\n");}condicion DO sentencias ENDWHILE; 
iteracion: FOR { printf("FOR\n");}iterador DO sentencias ENDFOR;
ciclo_especial: WHILE { printf("CICLO ESPECIAL\n");}iterador DO sentencias ENDWHILE;

condicion: 	comparacion | 
			condicion OP_LOG comparacion | 
			OP_NOT comparacion;
comparacion:  P_A expresion OP_COMPARACION expresion P_C;

iterador: ID IN lista_expresiones | ID TO expresion;
lista_expresiones: CORCH_A expresiones CORCH_C;
expresiones: expresion | expresiones COMA expresion;

expresion: termino |expresion OP_SURES termino ;
termino: factor | termino OP_MULTDIV factor;
factor: P_A expresion P_C | ID | constante  | funcion_take;

funcion_take: TAKE P_A operador PUNTO_COMA CONST_INT PUNTO_COMA lista_constantes_ent P_C;
operador: OP_SURES|OP_MULTDIV;
lista_constantes_ent: CORCH_A constantes_ent CORCH_C;
constantes_ent: CONST_INT|constantes_ent COMA CONST_INT;

constante: CONST_INT | CONST_REAL | CONST_STR;

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
	system ("Pause");
	exit (1);
}

