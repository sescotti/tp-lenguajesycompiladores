%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
FILE  *yyin;
int yylval;
float yyfval;
int numberLine, numberChar;
%}
%option noyywrap  
%option yylineno 

DIGITO					[0-9]
LETRA					[a-zA-Z]
CONST_STR               \".{1,30}\"
COMENTARIOS             \-\/({LETRA}|{DIGITO}|.)+\/\-
CONST_REAL              {DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}* 
CONST_INT               {DIGITO}+
ID						{LETRA}({LETRA}|{DIGITO}|_)*	
SUM_RES	                ["+"|"-"]
MULT_DIV	            ["*"|"/"]


%%
"program"		  { return PROGRAM;}
"var"			    { return VAR;}
"endvar"		  { return ENDVAR;}
"beginp"		  { return BEGINP;}
"endp"			  { graba_TS(); return ENDP; }
"take"			  { return TAKE;}
"real"			  { return REAL;}
"integer"		  { return INTEGER;}
"string"		  { return STRING;}
"if"			    { return IF;}
"then"   		  { return THEN;}
"else"   		  { return ELSE;}
"endif"	      { return ENDIF;}
"for"			    { return FOR;}
"to"		      { return TO;}
"endfor"		  { return ENDFOR;}
"while"	      { return WHILE;}
"do"	        { return DO;}
"endwhile"  	{ return ENDWHILE;}
"in"	        { return IN;}
"repeat"		  { return REPEAT;}
"until"			  { return UNTIL;}
":="			    { return OP_AS; }
":"				    { return DEF_TIPO;}
";"				    { return PUNTO_COMA; }
"["				    { return CORCH_A;}
"]"				    { return CORCH_C;}
"("				    { return P_A;}
")"				    { return P_C;}
","				    { return COMA;}
"++"			    { return CONCAT_STRING; }
"=<"          { return OP_COMPARACION; }
">="          { return OP_COMPARACION; }
"><"          { return OP_COMPARACION; }
"<"           { return OP_COMPARACION; }
"=="          { return OP_COMPARACION; }
">"           { return OP_COMPARACION; }
{SUM_RES}		  { return OP_SURES;}
{MULT_DIV}		{ return OP_MULTDIV;}
"and"        	{ return OP_LOG;}
"or"        	{ return OP_LOG;}
"not"        	{ return OP_NOT;}
"WRITE"			  { return WRITE;}
"READ"			  { return READ;}
{ID}			    { printf("Encontre un ID %s\n", yytext);
                inserta_TS("ID","---"); 
                return ID;}
{CONST_INT}		{ if(!validar_cota_int()) yyterminate(); inserta_TS("CONST_INT",yytext); return CONST_INT;}
{CONST_STR}		{ inserta_TS("CONST_STR",yytext); return CONST_STR;}
{CONST_REAL}	{ if(!validar_cota_real()) yyterminate(); inserta_TS("CONST_REAL",yytext); return CONST_REAL;}
{COMENTARIOS}	{ printf("FLEX:Encontre comentario %s\n",yytext);  }
"\n"      		{ ++numberLine; }
"\t"		

	
%%

/*CODIGO EN C*/
/***********************INICIO DECLARACIONES*****************************/
typedef struct{
        int posicion;
        char nombre[30];
        char tipo[20];
        char valor[100];
        int longitud;
        } TS_reg;
		
TS_reg tabla_simb[100];
int cant_entradas = 0;
FILE* pf_TS;

int busca_en_TS(char*);
int graba_TS();
int inserta_TS(char*,char*);

int validar_cota_int();
int validar_cota_real();
/***********************FIN DECLARACIONES********************************/

/***********************INICIO VALIDACION DE COTAS***********************/
int  validar_cota_int()
{
	int valor = atoi(yytext);
	if(valor >32767 || valor < -32768)
	{
		printf("SINTAX ERROR: INT OVERFLOW\n");		
		return 0;
	}
	return 1;
}

int  validar_cota_real()
{
	int valor = atoi(yytext);
	if(valor >32767 || valor < -32768)
	{
		printf("SINTAX ERROR: REAL OVERFLOW\n");		
		return 0;
	}
	return 1;
}
/***********************FIN VALIDACION DE COTAS***********************/

/***********************INICIO TABLA DE SIMBOLOS************************/
//Buscamos que no la hayamos guardado
int busca_en_TS(char* nombre)
{
    int i;
    for(i = 0; i<cant_entradas; i++)
    {
          if(!strcmp(tabla_simb[i].nombre, nombre))
          {
                 return i;
          }
    }
    
    return -1;
}

int inserta_TS(char* tipo,char* valor)
{
	 if((yylval = busca_en_TS(yytext)) == -1)
     {
		TS_reg reg;
		strcpy(reg.nombre, yytext);
		strcpy(reg.tipo, tipo);
		strcpy(reg.valor, valor);
		reg.longitud = strlen(yytext);
		reg.posicion = cant_entradas;
		tabla_simb[cant_entradas++] = reg;
		
		return yylval = cant_entradas-1;
	 }
	 return 0;
}

int graba_TS()
{
     int i;
     char* TS_file = "ts.txt";
     
     if((pf_TS = fopen(TS_file, "w")) == NULL)
     {
               printf("Error al grabar la tabla de simbolos \n");
               exit(1);
     }
     
     fprintf(pf_TS, "POSICION \t\t NOMBRE \t\t TIPO \t\t VALOR \t\t LONGITUD \n");
     
      for(i = 0; i < cant_entradas; i++)
      {
           fprintf(pf_TS,"%d \t\t\t\t %s \t\t\t", tabla_simb[i].posicion, tabla_simb[i].nombre);
           
          
            if(tabla_simb[i].tipo != NULL)
               fprintf(pf_TS,"%s \t\t\t", tabla_simb[i].tipo);
           
          
            if(tabla_simb[i].valor != NULL)
               fprintf(pf_TS,"%s \t\t\t", tabla_simb[i].valor);
           
            fprintf(pf_TS,"%d \n", tabla_simb[i].longitud);
      }    
     fclose(pf_TS);
}
/***********************FIN TABLA DE SIMBOLOS************************/
