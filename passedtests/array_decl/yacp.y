%{
#include<stdio.h>
#include "gen.h"
#include "ntypes.h"
#include "codgen.h"
#include "codgen.c"

#define LINEHEIGHT 2

char *val, *nval;
int showtree;
int yylex();
int yyerror(char*);
%}

%union {
	int oper;
	struct Node *nPtr;
};

%token <oper> NUM ID INT CHAR
%type <oper> type
%type <nPtr> declaration array_ref pars array_refs


%%

declaration
	: type array_refs					{ $$=$2; }
	;

array_refs
	: array_ref ',' array_refs				{ $$ = $1; }
	| array_ref						{ $$ = $1; }
	;

array_ref
	: ID pars						{{
									struct Node *n = create_var(val, vNull, NULL);
									$$=create_oper(tARR, 2, n, $2);
									display_tree($$);
								}}
	;

pars
	:							{ $$=NULL; }
	| pars '[' NUM ']'					{{
									$$=create_oper(tARAC, 1, create_con(atoi(nval)));
									int i;
									for(i=0; $1 && i<$1->oper.nops; i++) {
										add_child($$, $1->oper.operands[i]);
									}
								}}
	;

type
	: INT							{ $$=$1; }
	| CHAR							{ $$=$1; }
	;


