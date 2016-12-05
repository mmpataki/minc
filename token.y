
%{

#define __rodata__ "rodata"
#define __textdata__ "textdata"

#define LINEHEIGHT 2

#include<stdio.h>
#include<stdlib.h>
#include "gen.h"
#include "ntypes.h"
#include "codgen.h"
#include "codgen.c"

extern char *yytext, *varname, *numStr, *string_const;
int showtree = 0;

void add_child(struct Node *parent, struct Node *child);
int yylex();
int yyerror(char *);

%}

%union {
	int tokenId;
	char *vName;
        struct Node *nPtr;
};



%type <nPtr> program cprogram declarations fdeclaration function statement_list conditional statement block iexp eiexp funcall actarguments fsdecl fparamlist loops exp_hack for_loop while_loop c_switch switch_body aconst constant expression assign vdeclaration list sdecl pointer_expression

%type <nPtr> identifier

%type <tokenId> datatype

%token <tokenId> INT CHAR STRUCT UNION

%token <tokenId> FOR WHILE

%token <tokenId> IF ELSE

%token <tokenId> SWITCH CASE

%token <tokenId> BREAK CONTINUE RETURN

%token <tokenId> IDENTIFIER NUMBER

%token <tokenId> PLUS MINUS MUL DIV

%token <tokenId> LE GE LT GT EE NE 

%token <tokenId> AMP

%token <tokenId> AND OR NOT 

%token <tokenId> COLON

%token <tokenId> EQ
%token <tokenId> COMMA
%token <tokenId> OSB CSB
%token <tokenId> OB CB
%token <tokenId> OP CP
%token <tokenId> SEMICOLON
%token <tokenId> S_LIT C_LIT
%token <tokenId> INCOP DECOP



%right COMMA
%left CB CP
%right OP OB
%left PLUS MINUS
%left MUL DIV
%left LE GE GT LT EE NE
%left AND OR NOT
%right EQ
%%


