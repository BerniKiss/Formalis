%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "1.tab.h"

int column = 1;
%}

%option yylineno noyywrap

%%

"e" {
    column += yyleng;
    return EGESZ;
}

"v" {
    column += yyleng;
    return VALOS;
}

"ha" {
    column += yyleng;
    return HA;
}

"amig" {
    column += yyleng;
    return AMIG;
}

"kulonben" {
    column += yyleng;
    return KULONBEN;
}

"ki" {
    column += yyleng;
    return KI;
}

"be" {
    column += yyleng;
    return BE;
}

"lt" {
    column += yyleng;
    return LT;
}

"gt" {
    column += yyleng;
    return GT;
}

[0-9]+\.[0-9]+ {
    yylval.valos = atof(yytext);
    column += yyleng;
    return FLOAT;
}

[0-9]+ {
    yylval.egesz = atoi(yytext);
    column += yyleng;
    return INTEGER;
}

[a-zA-Z][a-zA-Z0-9]* {
    yylval.valt = strdup(yytext);
    column += yyleng;
    return NEV;
}

"==" {
    column += yyleng;
    return EQ;
}

"!=" {
    column += yyleng;
    return NE;
}

"<=" {
    column += yyleng;
    return LE;
}

">=" {
    column += yyleng;
    return GE;
}

"=" {
    column += yyleng;
    return ASSIGN;
}

":" {
    column += yyleng;
    return ':';
}


";" {
    column += yyleng;
    return ';';
}

"+" {
    column += yyleng;
    return '+';
}

"-" {
    column += yyleng;
    return '-';
}

"*" {
    column += yyleng;
    return '*';
}

"/" {
    column += yyleng;
    return '/';
}

"(" {
    column += yyleng;
    return '(';
}

")" {
    column += yyleng;
    return ')';
}

[ \t\r]+    { column += yyleng; }
\r?\n       { column = 1; }

. {
    fprintf(stderr, "Lexikalis hiba: '%s' a %d. sorban, %d. oszlopban\n",
            yytext, yylineno, column);
    column += yyleng;
}

%%