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
    int intval;
    double floatval;
    char* strval;
}

%token <intval> INTEGER
%token <floatval> FLOAT
%token <strval> IDENTIFIER

%token EGESZ VALOS
%token HA AKKOR KULONBEN AMIG
%token KI BE
%token LT GT
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
    | statement program
    ;

statement:
    declaration ';'
    | assignment ';'
    | input_statement ';'
    | output_statement ';'
    | if_statement
    | while_statement
    | error ';' {
        yyerror("Hiba az utasitasban, folytatom a kovetkezo pontosvesszonal");
        yyerrok;
    }
    ;

declaration:
    EGESZ IDENTIFIER
    | VALOS IDENTIFIER
    | EGESZ error {
        yyerror("Hianyzo vagy hibas valtozonev az egesz deklaracioban");
        yyerrok;
    }
    | VALOS error {
        yyerror("Hianyzo vagy hibas valtozonev a valos deklaracioban");
        yyerrok;
    }
    ;

assignment:
    IDENTIFIER ASSIGN expression
    ;

input_statement:
    BE IDENTIFIER
    ;

output_statement:
    KI expression
    ;

if_statement:
    HA '(' condition ')' ':' statement %prec THEN
    | HA '(' condition ')' ':' statement KULONBEN statement
    ;

while_statement:
    AMIG '(' condition ')' ':' statement
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
    | IDENTIFIER
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