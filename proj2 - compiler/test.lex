%{
#include <stdlib.h>
#include "node.h"
#include "test.tab.h"
%}
%option noyywrap

white [ \t\n]+
letter [a-zA-Z]
num [1-9][0-9]*|0
boollit false|true
ident [A-Z][A-Z0-9]*
word [letter]+

%%
{white} { /* ignoring whitespace */ }

"if"        return(IF);
"then"      return(THEN);
"else"      return(ELSE);
"begin"     return(BGN);
"end"       return(END);
"while"     return(WHILE);
"do"        return(DO);
"program"   return(PROGRAM);
"var"       return(VAR);
"as"        return(AS);
"int"       return(INT);
"bool"      return(BOOL);

"*"         return(OP2);
"div"       return(OP2);
"mod"       return(OP2);

"+"         return(OP3);
"-"         return(OP3);

"="         return(OP4);
"!="        return(OP4);
">"         return(OP4);
"<"         return(OP4);
">="        return(OP4);
"<="        return(OP4);

"("         return(LEFT_PARENTHESIS);
")"         return(RIGHT_PARENTHESIS);
":="        return(ASGN);
";"         return(SC);

"writeInt"  return(WRITEINT);
"readInt"   return(READINT);

{num}       return(yylval.ival = yytext[0]);
{ident}     return(yylval.ival = yytext[0]); 
{boollit}   return(yylval.ival = yytext[0]); 
%%
