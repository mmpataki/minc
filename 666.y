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

