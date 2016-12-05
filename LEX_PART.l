
%{
 #include<stdio.h>
 #include"y.tab.h"

 char *new_cstr(char*);
 char *varname, *numStr, *string_const;
%}

%%

"int"           {ECHO; return INT;}
"char"          {ECHO; return CHAR;}
"struct"	{ECHO; return STRUCT;}
"union"		{ECHO; return UNION;}

"for"           {ECHO; return FOR;}
"while"         {ECHO; return WHILE;}

"if"            {ECHO; return IF;}
"else"          {ECHO; return ELSE;}

"switch"        {ECHO; return SWITCH;}
"case"          {ECHO; return CASE;}

"break"         {ECHO; return BREAK;}
"continue"      {ECHO; return CONTINUE;}
"return"        {ECHO; return RETURN;}

[0-9]+          {ECHO; return NUMBER;}

[a-zA-Z]+[a-zA-Z0-9]* {ECHO; varname=new_cstr(yytext); return IDENTIFIER;}


"++"             {ECHO; return INCOP;}
"--"             {ECHO; return DECOP;}
"+"              {ECHO; return PLUS;}
"-"              {ECHO; return MINUS;}
"*"              {ECHO; return MUL;}
"/"              {ECHO; return DIV;}

"<="             {ECHO; return LE;}
">="             {ECHO; return GE;}
"<"              {ECHO; return LT;}
">"              {ECHO; return GT;}
"=="             {ECHO; return EE;}
"!="             {ECHO; return NE;}

"&&"             {ECHO; return AND;}
"||"             {ECHO; return OR;}
"!"              {ECHO; return NOT;}
"&"		 {ECHO; return AMP;}
"="              {ECHO; return EQ;}

"("              {ECHO; return OP;}
")"              {ECHO; return CP;}
"{"              {ECHO; return OB;}
"}"              {ECHO; return CB;}
"["              {ECHO; return OSB;}
"]"              {ECHO; return CSB;}

","              {ECHO; return COMMA;}
";"              {ECHO; return SEMICOLON;}
":"		 {ECHO; return COLON;}

"/*".*"*/"[ \t\n]* {ECHO; ;}
\".*\"           {ECHO; string_const = new_cstr(yytext); return S_LIT;}
[ \t\n]+         {ECHO;}
.		 {ECHO;}
%%

int yywrap()
{
	return 1;
}

