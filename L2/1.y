%{
#include <stdio.h>
#include <stdlib.h>

int yyerror(const char *s);
extern int yylex();
extern int yylineno;
extern int column;
extern char* yytext;
%}

%union {
    int egesz;
    double valos;
    char* valt;
}

%token <egesz> INTEGER
%token <valos> FLOAT
%token <valt> NEV

%token EGESZ
%token VALOS
%token HA
%token KULONBEN
%token AMIG
%token KI
%token BE
%token LT
%token GT
%token EQ NE LE GE
%token ASSIGN

%define parse.error verbose

%start program

%left LT GT EQ NE LE GE
%left '+' '-'
%left '*' '/'
%right NEG

%%

program:
    | program utasitas
    ;

utasitas:
    egyszeru_utasitas ';'
    | complex_utasitas
    | error ';' {
        fprintf(stderr, "Hiba az utasitasban - helyreallitas...\n");
        yyerrok;
    }
    ;

egyszeru_utasitas:
    declaration
    | assignment
    | input
    | output
    ;

complex_utasitas:
    if_utasitas
    | while_utasitas
    ;

declaration:
    tipus NEV
    | tipus NEV ASSIGN expression
    | tipus error {
        fprintf(stderr, "Hianyzo vagy hibas valtozonev a deklaracioban\n");
        yyerrok;
    }
    ;

tipus:
    EGESZ
    | VALOS
    ;

assignment:
    NEV ASSIGN expression
    ;

input:
    BE NEV
    ;

output:
    KI expression
    ;

if_utasitas:
    HA '(' condition ')' blokk
    | HA '(' condition ')' blokk KULONBEN blokk
    ;

while_utasitas:
    AMIG '(' condition ')' blokk
    ;

blokk:
    '{' utasitas_lista '}'
    | '{' '}'
    ;

utasitas_lista:
    utasitas
    | utasitas_lista utasitas
    ;

condition:
    expression EQ expression
    | expression NE expression
    | expression LT expression
    | expression GT expression
    | expression LE expression
    | expression GE expression
    | LT expression GT expression
    ;

expression:
    INTEGER
    | FLOAT
    | NEV
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | '(' expression ')'
    | '-' expression %prec NEG
    ;

%%

int main() {
    printf("Szintaktikai elemzes indul...\n");
    if (yyparse() == 0) {
        printf("OK!\n");
    } else {
        printf("Hiba tortent az elemzes soran.\n");
    }
    return 0;
}

int yyerror(const char *s) {
    fprintf(stderr, "Szintaktikai hiba a %d. sorban, %d. oszlopban: %s\n",
            yylineno, column, s);
    fprintf(stderr, "A hiba kozeleben: '%s'\n", yytext);
    return 0;
}