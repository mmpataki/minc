%{
#include "y.tab.h"
extern char *val, *nval;
extern char *new_cstr(char *str);
%}

%%
[0-9]+		{
			ECHO;
			nval = new_cstr(yytext);
			return NUM;
		}
"int"		{ ECHO; return INT; }
"char"		{ ECHO; return CHAR;}
[a-zA-Z]+	{ 
			ECHO; 
			val = new_cstr(yytext);
			return ID;
		}
[\[\],();]	{ ECHO; return *yytext; }
.		{ ECHO; }
%%

int yywrap() { return 1; }

