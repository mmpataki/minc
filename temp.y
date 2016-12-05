
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


program
	: cprogram						{ $$ = $1; printf("\nValid C Code\n"); }
	;

cprogram
	:							{ $$ = NULL; }
	| cprogram declarations					{ $$ = $1; }
	| cprogram function					{ $$ = $1; }
	;

declarations
	: vdeclaration						{ $$ = $1; }
	| fdeclaration						{ $$ = $1; }
	;

identifier
	: IDENTIFIER						{
									$$ = create_var(varname, vNull, NULL);
								}
	;

fdeclaration
	: datatype identifier OP fparamlist CP			{
									printf("Function declaration");
									$2->var.type = vFunc; }
	;

function
	: datatype identifier OP fparamlist CP block 		{
									$2->var.type = vFunc;
									$$ = create_oper(tFUNCTION, 3, $6, $4, $2);
									if(showtree) {
										display_tree($$);
									}
									puts("\n\n");
									gen_code($$);
								}
	;

statement_list
	:							{ $$ = NULL; }
	| statement_list statement				{
									$$ = create_oper(tSTATEMENTS, 1, $2);
									int stmts;
									for(stmts=0; $1 && (stmts < $1->oper.nops); stmts++) {
										add_child($$, $1->oper.operands[stmts]);
									}
								}
	| statement_list declarations SEMICOLON			{  }
	;

conditional
	: iexp							{ $$ = $1; }
	| c_switch						{ $$ = $1; }
	;

statement
	: expression SEMICOLON					{ $$ = $1; }
	| RETURN expression SEMICOLON				{ $$ = create_oper(tRETURN, 1, $2); }
	| BREAK SEMICOLON					{ $$ = create_oper(tBREAK, 0); }
	| assign SEMICOLON					{ $$ = $1; }
	| loops							{ $$ = $1; }
	| block							{ $$ = $1; }
	| conditional						{ $$ = $1; }
	;

block
	: OB statement_list CB					{ $$ = $2; }
	;
iexp
	: IF OP expression CP statement eiexp			{ $$ = create_oper(tIF, 3, $6, $5, $3); }
	;
eiexp
	:							{ $$ = NULL; }	
	| ELSE statement					{ $$ = $2; }
	;

funcall
	: identifier OP actarguments CP				{ $$ = create_oper(tCALL, 2, $3, $1); }
	;

actarguments
	: expression						{ $$ = create_oper(tAPARAMS, 1, $1); }
	| expression COMMA actarguments				{
									$$ = create_oper(tAPARAMS, 1, $1);

									int actargs=0;
									for(actargs=0; actargs < $3->oper.nops; actargs++) {
										add_child($$, $3->oper.operands[actargs]);
									}
								}
	;

fsdecl
	: datatype identifier					{ 
									$2->var.type = vInt;
									$$ = $2;
								}
	;

fparamlist
	:							{ $$ = NULL; }
        | fsdecl						{ $$ = create_oper(tFPARAMS, 1, $1); }
	| fsdecl COMMA fparamlist				{
									$$ = create_oper(tFPARAMS, 1, $1);
									int fargs;
									for(fargs=0; fargs<$3->oper.nops; fargs++) {
										add_child($$, $3->oper.operands[fargs]);
									}
								}
	;

loops
	: for_loop 								{ $$ = $1; }
	| while_loop								{ $$ = $1; }
	;

exp_hack
	: expression								{ $$ = $1; }
	| assign								{ $$ = $1; }
	;
	

for_loop
	: FOR OP exp_hack SEMICOLON exp_hack SEMICOLON exp_hack CP statement	{ $$ = create_oper(tFOR, 4, $9, $7, $5, $3); }
	;
          
while_loop
	: WHILE OP expression CP statement					{ $$ = create_oper(tWHILE, 2, $5, $3); }
	;

c_switch
	: SWITCH OP expression CP OB switch_body CB				{ $$ = create_oper(tSWITCH, 2, $6, $3); }
	;

switch_body
	:									{ $$ = NULL; }
	| switch_body CASE aconst COLON statement_list				{ $$ = create_oper(tCASE, 2, $5, $3); }
	;
      
aconst
	: NUMBER								{ $$ = create_con(atoi(yytext)); }
//	| C_LIT 								{ $$ = create_con($1); }
	;

datatype 
	: INT									{ $$ = $1; }
	| CHAR									{ $$ = $1; }
//	| STRUCT IDENTIFIER OB vdeclaration CB
//	| UNION IDENTIFIER OB vdeclaration CB
	;

constant
	: S_LIT									{ $$ = create_scon(string_const); }
	| aconst 								{ $$ = $1; }
	;

expression
	:						{ $$ = NULL; }
	| expression 	PLUS 	expression		{ $$ = create_oper(tPLUS,  2, $3, $1); }
        | expression 	MINUS 	expression              { $$ = create_oper(tMINUS,  2, $3, $1); }
        | expression 	MUL 	expression              { $$ = create_oper(tMULTIPLY,  2, $3, $1); }
        | expression 	DIV 	expression              { $$ = create_oper(tDIVIDE,  2, $3, $1); }
        | expression 	GT 	expression              { $$ = create_oper(tGT,  2, $3, $1); }
        | expression 	LT 	expression              { $$ = create_oper(tLT,  2, $3, $1); }
	| expression	LE	expression		{ $$ = create_oper(tLE, 2, $3, $1); }
        | expression 	GE 	expression              { $$ = create_oper(tGE, 2, $3, $1); }
        | expression 	EE 	expression              { $$ = create_oper(tEE, 2, $3, $1); }
        | expression 	NE 	expression              { $$ = create_oper(tNE, 2, $3, $1); }
        | expression 	AND 	expression              { $$ = create_oper(tAND, 2, $3, $1); }
        | expression 	OR 	expression              { $$ = create_oper(tOR, 2, $3, $1); }

	| identifier	INCOP				{ $$ = create_oper(tINCOP, 1, $1); }
	| identifier	DECOP				{ $$ = create_oper(tDECOP, 1, $1); }

	| NOT	expression				{ $$ = create_oper(tNOT, 1, $2); }
	| AMP identifier				{ $$ = create_oper(tAMP, 1, $2); }
	| funcall					{ $$ = $1; }
	| identifier arrsize				{ $$ = $1; }
	| constant					{ $$ = $1; }

	/* | pointer_expression				{ $$ = $1; } */

	| OP expression CP				{ $$ = $2; }
	;

assign	
	: identifier EQ expression			{ $$ = create_oper(tEQ,  2, $3, $1); }
	| pointer_expression EQ expression		{ $$ = create_oper(tPOINTER, 1, $3); }
	;

pointer_expression
	: MUL identifier %prec MUL			{ $2->type = vPointer; }	/* '*' defined as MUL */
	;
		
vdeclaration
 	: datatype list					{ 
								int vdecappl;
								for(vdecappl=0; vdecappl<$2->oper.nops; vdecappl++) {
									((struct Node*)$2->oper.operands[vdecappl])->var.type = $1;
								}
							}
	;
list
	: list COMMA sdecl				{ 
								/* just creating a dummy var so that we can pass a list 
								 * to the upper rule vdeclaration which applies the
								 * data-type id to each variable
								 */
								$$ = create_oper(-1, 1, $3);
								int vdecs;
								if($1->type == typeOp) {
									for(vdecs=0; vdecs < $1->oper.nops; vdecs++) {
										add_child($$, $1->oper.operands[vdecs]);
									}
								} else {
									add_child($$, $1);
								}
							}
	| sdecl						{ $$ = $1; }
	;

arrsize
	:
	| OSB constant CSB				{ }
	;

sdecl	
	: identifier arrsize				{ $$ = $1; }
	| identifier arrsize EQ expression		{ $$ = $1; }
	| pointer_expression arrsize			{ $$ = $1; }
	| pointer_expression arrsize EQ expression	{ $$ = $1; }
	;

%%

int yyerror(char *x) {
	printf("Illegal C program\nERROR:%s",x);
}

int main(int argc, char *argv[]) {

	if(argc == 2) {
		if(!strcmp("-tree", argv[1])) {
			showtree = 1;
		}
	}

	printf("\nEnter a C Code :\n\n");
        yyparse();

	//system("mv "__rodata__" test.s");
	//system("cat "__textdata__" >> test.s");
	//system("rm "__textdata__);
}


struct Node *create_scon(char *val) {
        struct Node *n;

        if((n = (struct Node*)malloc(sizeof(struct Node))) == NULL) {
                printf("malloc fail\n");
                exit(0);
        }
        n->type = typeScon;
        n->con.strVal = val;
        return n;
}

struct Node *create_con(long long int val) {
        struct Node *n;

        if((n = (struct Node*)malloc(sizeof(struct Node))) == NULL) {
                printf("malloc fail\n");
                exit(0);
        }
        n->type = typeCon;
        n->con.val = val;
        return n;
}


#include "symtab.h"

char *new_cstr(char *str) {
        char *n = (char*)malloc(sizeof(char) * (strlen(str)+1));
        strcpy(n, str);
        return n;
}

void set_type(struct Node *n, int type) {
}

struct Node *create_var(char *name, int type, void *extra) {

        struct Node *n;

        if((n = sym_lookup(name))) {
                return n;
        }

        if((n = (struct Node*)malloc(sizeof(struct Node))) == NULL) {
                printf("malloc failed\n");
                exit(0);
        }

        n->type = typeVar;
        n->var.type = typeVar;
        n->var.name = new_cstr(name);
	n->var.extra = extra;
	n->hits = 0;
	n->reg = ANYREG;
	n->sfof = stack_pointer;
	stack_pointer += 4;			/* assume 4 byte size */
        insert_symtab(n);
        return n;
}

struct Node *create_oper(int type, int nops, ...) {
        struct Node *n;
        int i;
        va_list ap;

        if((n = (struct Node*)malloc(sizeof(struct Node))) == NULL) {
                printf("malloc failed\n");
                exit(0);
        }
        n->type = typeOp;
        n->oper.op = type;
        n->oper.nops = nops;
        n->oper.operands = malloc(sizeof(struct Node*) * nops);

        va_start(ap, nops);
        for (i = 0; i < nops; i++) {
                n->oper.operands[i] = (void*)va_arg(ap, struct Node*);
        }

        va_end(ap);
        return n;
}

int depth, _pline_buffer_init__=0;
void print_tree(struct Node *, int);

char _pline_buffer__[512];

void display_tree(struct Node *root) {
	int i;
	depth = 0;
	if(_pline_buffer_init__==0) {
		for(i=0; i<512; i++) {
			_pline_buffer__[i] = ' ';
		}
		_pline_buffer_init__ = 1;
	}
	print_tree(root, 1);
	printf("\n\n");
}

#ifndef LINEHEIGHT
#define LINEHEIGHT 1
#endif

void print_tree(struct Node* root, int last)
{

	if(depth == 0) {
		printf("\n\n");
	}

        int tab,  i;

	for(i=0; i<LINEHEIGHT; i++) {
	        for( tab=0; tab<depth; tab++ ) {
			printf("%c     ", _pline_buffer__[tab]);
	        }
		if(i == 0) {
			printf("|\n");
		}
	}
	printf("%c-----", last?'+':'|');

	if(!root) {
		puts("(nil.)");
		return;
	}

	++depth;
	_pline_buffer__[depth] = '|';

	if( root->type == typeCon ) {
		printf("[constant { value : %lld } ]\n", root->con.val);
	}

        if( root->type == typeOp ) {

		printf("[node: %s ]\n", NODETYPES[root->oper.op]);

		for(i=root->oper.nops-1; i > -1; i--) {
			if(i == 0) {
				_pline_buffer__[depth] = ' ';
			}
			print_tree((struct Node*)root->oper.operands[i], !i);
		}
	}

	if( root->type == typeVar ) {
		printf("[variable { name : %s, symoff : %d} ]\n", root->var.name, root->var.symoff);
        }
	if( root->type == typeScon ) {
		printf("[string-literal {value : %s} ]\n", root->con.strVal);
	}
	--depth;
}

void add_child(struct Node *parent, struct Node *child) {

	void **newn;
	int i;

	if(parent->type != typeOp) return;

	newn = malloc(sizeof(struct Node*) * (parent->oper.nops+1));
	if(!newn) return;

	for(i=0; i<parent->oper.nops; i++) {
		newn[i] = parent->oper.operands[i];
	}
	newn[i] = child;
	parent->oper.nops++;
	free(parent->oper.operands);
	parent->oper.operands = newn;
}

