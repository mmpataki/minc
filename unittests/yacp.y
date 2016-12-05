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

%token <oper> NUM ID INT CHAR DEFINE SCONST
%type <oper> type constant
%type <nPtr> declaration array_ref pars array_refs program formal_params


%%

program
	: program declaration					{ $$ = $2; }
	|							{ $$ = NULL; }
	;

declaration
	: type array_refs					{ $$ = $2; }
	| type ID '(' formal_params ')' ';'			{ $$ = $4; }
	| DEFINE ID constant					{ $$ = NULL; }
	;

constant
	: NUM							{ $$ = $1; }
	| SCONST						{ $$ = $1; }
	;

formal_params
	: type ID						{ $$ = NULL; }
	| type ID ',' formal_params				{ $$ = NULL; }
	| declaration						{ $$ = $1; }
	;

array_refs
	: array_refs ',' array_ref				{ $$ = $1; }
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
	: '[' NUM ']'						{ $$ = create_oper(tARAC, 1, create_con(atoi(nval))); }
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


