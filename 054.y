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

