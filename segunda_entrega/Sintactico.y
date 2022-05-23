 %{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "arbol.h"


struct struct_tablaSimbolos
{
	char nombre[100];
	char tipo[100];
	char valor[50];
	char longitud[100];
};

int yystopparser=0;
FILE  *yyin;

int yylex();
int yyerror();
extern struct struct_tablaSimbolos tablaSimbolos[1000]; 
extern int puntero_array;
int contadorTipos = 0;
int contadorVar = 0;
char* auxTipoDato;
char matrizTipoDato[100][10];
char matrizVariables[100][10];
int contadorId = 0;
int agregarTipoEnTablaSimbolos(char* nombre, int contadorId);
void mensaje_error(char*);
void escribirEnTablaSimbolos();

FILE *f_intermedia;

// Declaración punteros arbol
t_nodo* ptr_star; //star
t_nodo* ptr_prog; //programa
t_nodo* ptr_zona; //zona_declaracion
t_nodo* ptr_decls; //declaraciones
t_nodo* ptr_decl; //declaracion
t_nodo* ptr_list_dec; //lista_declaracion
t_nodo* ptr_list_var; //lista_var
t_nodo* ptr_list_tip; //lista_tipo
t_nodo* ptr_algo; //algoritmo
t_nodo* ptr_bloq; //bloque
t_nodo* ptr_sent; //sentencia
t_nodo* ptr_cicl; //ciclo
t_nodo* ptr_asig; //asignacion
t_nodo* ptr_sele; //seleccion
t_nodo* ptr_true; //Rama verdadera
t_nodo* ptr_false;//Rama falsa
t_nodo* ptr_cond; //condicion
t_nodo* ptr_comp; //comparacion
t_nodo* ptr_expr; //expresion
t_nodo* ptr_inli; //inlist
t_nodo* ptr_list_exp; //lista_expresiones
t_nodo* ptr_betw; //between
t_nodo* ptr_term; //termino
t_nodo* ptr_fact; //factor
t_nodo* ptr_entr; //entrada
t_nodo* ptr_sali; //salida

%}
%token PROGRAM
%token END
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token WRITE
%token READ
%token BETWEEN
%token INLIST
%token DECVAR
%token ENDDEC
%token COMP_IGUAL
%token COMP_MAYOR
%token COMP_MENOR
%token COMP_MAYOR_IGUAL
%token COMP_MENOR_IGUAL
%token COMP_DISTINTO
%token OPAR_ASIG
%token TIPO_INT
%token TIPO_FLOAT
%token TIPO_STRING
%token <num>CTE_ENTERA
%token <real>CTE_REAL
%token <str>CTE_STRING
%token OP_MAS 
%token OP_MENOS
%token OP_MULT
%token OP_DIV
%token OP_LOG_AND
%token OP_LOG_OR
%token OP_LOG_NOT
%token DOS_PUNTOS
%token PUN_Y_COM
%token COMA
%token <strid>ID
%token PAR_A
%token PAR_C
%token LLAVE_A
%token LLAVE_C
%token COR_A
%token COR_C

%union{
char * strid;
char * num;
char * real; 
char * str;
}

%%
start: programa {ptr_star = ptr_prog; inOrder(&ptr_star, f_intermedia);};

programa: PROGRAM zona_declaracion algoritmo END {ptr_prog = crearNodo("programa", ptr_zona, ptr_algo); printf("\n***** Compilacion exitosa: OK *****\n");};
				  
zona_declaracion:	declaraciones {ptr_zona = ptr_decls;};

declaraciones:	declaracion {ptr_decls = ptr_decl;}
				|declaraciones declaracion {
					ptr_decls = crearNodo("declaraciones", ptr_decls, ptr_decl);};

declaracion:	DECVAR { printf("***** Inicio declaracion de variables *****\n"); } lista_declaracion ENDDEC {ptr_decl= ptr_list_dec; printf("*****\n Fin declaracion de variables *****\n");};

lista_declaracion:	lista_var DOS_PUNTOS lista_tipo {ptr_list_dec = crearNodo("dec", ptr_list_var, ptr_list_tip);}
					| lista_declaracion lista_var DOS_PUNTOS lista_tipo {ptr_list_dec = crearNodo("lista_dec_vars", ptr_list_dec, crearNodo("dec", ptr_list_var, ptr_list_tip));}


lista_var:		ID {strcpy(matrizVariables[contadorId],yylval.strid) ;  contadorId++;contadorVar++;
					ptr_list_var = crearHoja($1);
					}
				| lista_var COMA ID {strcpy(matrizVariables[contadorId],yylval.strid) ; contadorId++;contadorVar++;
									ptr_list_var = crearNodo("list_var", ptr_list_var, crearHoja($3));
									};

 
lista_tipo:		TIPO_INT { auxTipoDato="int"; ptr_list_tip = crearHoja(auxTipoDato); for(int i = 0; i < contadorVar; ++i){strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf(" INT");} contadorVar=0; }
				|TIPO_FLOAT {  auxTipoDato="float"; ptr_list_tip = crearHoja(auxTipoDato); for(int i = 0; i < contadorVar; ++i){strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf(" REAL"); }contadorVar = 0; }
				|TIPO_STRING { auxTipoDato="string"; ptr_list_tip = crearHoja(auxTipoDato); for(int i = 0; i < contadorVar; ++i){strcpy(matrizTipoDato[contadorTipos],auxTipoDato); agregarTipoEnTablaSimbolos(matrizVariables[contadorTipos],contadorTipos); contadorTipos++; printf(" STRING");}contadorVar = 0; };
              

algoritmo:		bloque {ptr_algo = ptr_bloq; printf("\n***** Fin de bloque *****\n");};

bloque:			sentencia {ptr_bloq = ptr_sent;}
				|bloque sentencia {ptr_bloq = crearNodo("bloque", ptr_bloq, ptr_sent);};


sentencia:		asignacion { ptr_sent = ptr_asig; printf(" - asignacion - OK \n"); }
				|seleccion { ptr_sent = ptr_sele; printf(" - seleccion - OK \n"); }
				|ciclo { ptr_sent = ptr_cicl; printf(" - ciclo - OK \n"); }
				|entrada { ptr_sent = crearNodo("entrada", ptr_entr, NULL); printf(" - entrada - OK \n"); }
				|salida { ptr_sent = crearNodo("salida", ptr_sali, NULL); printf(" - salida - OK \n"); };

ciclo:			WHILE PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C {ptr_cicl = crearNodo("ciclo", ptr_cond, ptr_bloq);};
       
asignacion:		ID OPAR_ASIG expresion {ptr_asig = crearNodo(":=", crearHoja($1), ptr_expr);};
                  
          
seleccion: 		IF  PAR_A condicion PAR_C THEN bloque ENDIF {ptr_sele = crearNodo("if", ptr_cond, ptr_bloq);}
				| IF  PAR_A condicion PAR_C THEN bloque {ptr_true = ptr_bloq;} ELSE bloque {ptr_false = ptr_bloq;} ENDIF {ptr_sele = crearNodo("if", ptr_cond, crearNodo("else", ptr_true, ptr_false));};

condicion:		comparacion 
				|comparacion OP_LOG_AND comparacion
				|comparacion OP_LOG_OR comparacion	
				|comparacion OP_LOG_NOT comparacion
				|inlist { printf(" - inlist - OK \n"); };
				|between { printf(" - between - OK \n"); };

comparacion:	expresion COMP_IGUAL expresion {ptr_comp = crearNodo("==",ptr_entr,ptr_term);}  
				|expresion COMP_MAYOR expresion	{ptr_comp = crearNodo(">",ptr_entr,ptr_term);}   
				|expresion COMP_MENOR expresion {ptr_comp = crearNodo("<",ptr_entr,ptr_term);}  
				|expresion COMP_MAYOR_IGUAL expresion  {ptr_comp = crearNodo(">=",ptr_entr,ptr_term);}  
				|expresion COMP_MENOR_IGUAL expresion {ptr_comp = crearNodo("<=",ptr_entr,ptr_term);}  
				|expresion COMP_DISTINTO expresion {ptr_comp = crearNodo("!=",ptr_entr,ptr_term);} ;


expresion:		expresion { printf(" expresion"); } OP_MAS termino { printf(" termino"); ptr_expr=crearNodo("+",ptr_expr,ptr_term); }
				|expresion { printf(" expresion"); }OP_MENOS termino { printf(" termino"); ptr_expr=crearNodo("-",ptr_expr,ptr_term);}
				|termino { printf(" termino"); ptr_expr=ptr_term; };
				
inlist:			INLIST PAR_A ID PUN_Y_COM COR_A lista_expresiones COR_C PAR_C {
					ptr_inli = crearNodo("inlist", $3, ptr_list_exp)
				};

lista_expresiones:	lista_expresiones PUN_Y_COM expresion {
						ptr_list_exp = crearNodo("list_exp", ptr_list_exp, ptr_expr);
					}
                    | expresion {ptr_list_exp = ptr_expr;};
					
between:		BETWEEN PAR_A ID COMA COR_A expresion PUN_Y_COM expresion COR_C PAR_C;

termino:		termino OP_MULT factor { printf(" factor"); ptr_term=crearNodo("*",ptr_term,ptr_fact);}
				|termino OP_DIV factor { printf(" factor"); ptr_term=crearNodo("/",ptr_term,ptr_fact);}
				|factor { printf(" factor"); ptr_term=ptr_fact; };
                         

factor:			ID {ptr_fact = crearHoja($1); }
				|CTE_ENTERA {ptr_fact = crearHoja($1); }
				|CTE_REAL {ptr_fact = crearHoja($1); }
				|CTE_STRING {ptr_fact = crearHoja($1); }
				|PAR_A expresion PAR_C {;}
				;
 
entrada: 		READ ID {ptr_entr = crearHoja($2);};

salida:			WRITE CTE_STRING {ptr_sali = crearHoja($2);}
				|WRITE ID {ptr_sali = crearHoja($2);}; 
          
          
%%
 
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL){
	printf("\nERROR! No se pudo abrir el archivo: %s\n", argv[1]);
	return 1;
  }

  if ((f_intermedia = fopen("intermedia.txt", "wt")) == NULL){
	printf("\nERROR! No se pudo abrir el archivo intermedia\n");
	return 1;
  }
  
  yyparse();
  escribirEnTablaSimbolos();
  fclose(yyin);
  fclose(f_intermedia);
  system ("Pause");
  return 0;
}

int agregarTipoEnTablaSimbolos(char* nombre, int contadorTipos)
{     
		int i;          
        char lexema[50]; 
		lexema[0]='_';
		lexema[1]='\0';
		strcat(lexema,nombre);
                 
		for(i = 0; i < puntero_array; i++)
		{
			if(strcmp(tablaSimbolos[i].nombre, lexema) == 0)
			{
				if(tablaSimbolos[i].tipo[0] == '\0')
				strcpy(tablaSimbolos[i].tipo,matrizTipoDato[contadorTipos]);
		  
				return 1; 
			}
		}
	
	return 0;	
}
