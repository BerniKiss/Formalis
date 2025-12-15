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
%token AKKOR
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

%nonassoc THEN
%nonassoc KULONBEN

%%

program:
    | utasitasok program
    ;

utasitasok:
    egyszeru_utasitas ';' | complex_utasitas
    | error ';' {
        yyerror("Hiba az utasitasban");
        yyerrok;
    }
    ;

egyszeru_utasitas:
    declaration | assignment | input | output
    ;

complex_utasitas:
    if | while
    ;

declaration:
    tipus NEV
    | tipus NEV ASSIGN expression
    | tipus error {
        yyerror("Hianyzo vagy hibas valtozonev a deklaracioban");
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

if:
    HA '(' condition ')' ':' utasitas_blokk %prec THEN
    | HA '(' condition ')' ':' utasitas_blokk KULONBEN ':' utasitas_blokk
    ;

while:
    AMIG '(' condition ')' ':' utasitas_blokk
    ;

utasitas_blokk:
    egyszeru_utasitas ';'
    | complex_utasitas
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
    | '-' expression %prec '*'
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