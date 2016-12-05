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

