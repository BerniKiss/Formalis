%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yyerror(const char *s);
extern int yylex();
extern int yylineno;
extern int column;
extern char* yytext;

typedef struct {
    int isInteger;
    int isFloat;
} VariableType;

typedef struct SymbolNode {
    char* name;
    VariableType type;
    int line;
    int column;
    struct SymbolNode* next;
} SymbolNode;

SymbolNode* symbolTable = NULL;

void initSymbolTable() {
    symbolTable = NULL;
}

SymbolNode* lookupSymbol(const char* name) {
    SymbolNode* current = symbolTable;
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

int addSymbol(const char* name, VariableType type, int line, int col) {
    SymbolNode* existing = lookupSymbol(name);
    if (existing != NULL) {
        fprintf(stderr, "\n[SZEMANTIKAI HIBA] Ujradeklaralas!\n");
        fprintf(stderr, "  Valtozo: '%s'\n", name);
        fprintf(stderr, "  Eredeti deklaracio: %d. sor\n", existing->line);
        fprintf(stderr, "  Ujradeklaralas: %d. sor, %d. oszlop\n", line, col);
        return 0;
    }

    SymbolNode* newSymbol = (SymbolNode*)malloc(sizeof(SymbolNode));
    newSymbol->name = strdup(name);
    newSymbol->type = type;
    newSymbol->line = line;
    newSymbol->column = col;
    newSymbol->next = symbolTable;
    symbolTable = newSymbol;

    printf("[DEKLARACIO] '%s' (%s) - %d. sor, %d. oszlop\n",
           name,
           type.isInteger ? "egesz" : "valos",
           line, col);
    return 1;
}

int checkDeclared(const char* name, int line, int col) {
    SymbolNode* sym = lookupSymbol(name);
    if (sym == NULL) {
        fprintf(stderr, "\n[SZEMANTIKAI HIBA] Deklaralatlan valtozo!\n");
        fprintf(stderr, "  Valtozo: '%s'\n", name);
        fprintf(stderr, "  Hivatkozas: %d. sor, %d. oszlop\n", line, col);
        return 0;
    }
    return 1;
}

VariableType getSymbolType(const char* name) {
    SymbolNode* sym = lookupSymbol(name);
    VariableType undefined = {0, 0};
    if (sym == NULL) {
        return undefined;
    }
    return sym->type;
}

int checkTypeCompatibility(VariableType t1, VariableType t2, int line, int col, const char* operation) {
    if (t1.isInteger && t2.isFloat) {
        fprintf(stderr, "\n[SZEMANTIKAI HIBA] Tipus inkompatibilis!\n");
        fprintf(stderr, "  Muvelet: %s\n", operation);
        fprintf(stderr, "  Hely: %d. sor, %d. oszlop\n", line, col);
        fprintf(stderr, "  egesz es valos nem keverheto\n");
        return 0;
    }
    if (t1.isFloat && t2.isInteger) {
        fprintf(stderr, "\n[SZEMANTIKAI HIBA] Tipus inkompatibilis!\n");
        fprintf(stderr, "  Muvelet: %s\n", operation);
        fprintf(stderr, "  Hely: %d. sor, %d. oszlop\n", line, col);
        fprintf(stderr, "  valos es egesz nem keverheto\n");
        return 0;
    }
    return 1;
}

void printSymbolTable() {
    printf("\n=== SZIMBoLUMtaBLA ===\n");
    printf("%-15s %-10s %-10s %-10s\n", "Nev", "Tipus", "Sor", "Oszlop");
    printf("---------------------------------------------------\n");

    SymbolNode* current = symbolTable;
    while (current != NULL) {
        printf("%-15s %-10s %-10d %-10d\n",
               current->name,
               current->type.isInteger ? "egesz" : "valos",
               current->line,
               current->column);
        current = current->next;
    }
    printf("======================\n\n");
}

void freeSymbolTable() {
    SymbolNode* current = symbolTable;
    while (current != NULL) {
        SymbolNode* temp = current;
        current = current->next;
        free(temp->name);
        free(temp);
    }
    symbolTable = NULL;
}

%}

%union {
    int egesz;
    double valos;
    char* valt;
    VariableType vartype;
}

%token <egesz> INTEGER
%token <valos> FLOAT
%token <valt> NEV

%type <vartype> expression
%type <egesz> tipus

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
%token AND OR NOT

%define parse.error verbose

%start program

%left OR
%left AND
%right NOT
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
        fprintf(stderr, ">> Hibas utasitas - helyreallitas\n");
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
    tipus NEV {
        VariableType vt = {0, 0};
        if ($1 == EGESZ) {
            vt.isInteger = 1;
        } else {
            vt.isFloat = 1;
        }
        addSymbol($2, vt, yylineno, column);
        free($2);
    }
    | tipus NEV ASSIGN expression {
        VariableType vt = {0, 0};
        if ($1 == EGESZ) {
            vt.isInteger = 1;
        } else {
            vt.isFloat = 1;
        }
        addSymbol($2, vt, yylineno, column);
        checkTypeCompatibility(vt, $4, yylineno, column, "deklaracio ertekadas");
        free($2);
    }
    | tipus error {
        fprintf(stderr, ">> Hianyzo vagy hibas valtozonev a deklaracioban\n");
        yyerrok;
    }
    ;

tipus:
    EGESZ { $$ = EGESZ; }
    | VALOS { $$ = VALOS; }
    ;

assignment:
    NEV ASSIGN expression {
        if (checkDeclared($1, yylineno, column)) {
            VariableType varType = getSymbolType($1);
            checkTypeCompatibility(varType, $3, yylineno, column, "ertekadas");
        }
        free($1);
    }
    ;

input:
    BE NEV {
        checkDeclared($2, yylineno, column);
        free($2);
    }
    ;

output:
    KI expression
    ;

if_utasitas:
    HA '(' condition ')' blokk
    | HA '(' condition ')' blokk KULONBEN blokk
    | HA '(' error ')' blokk {
        fprintf(stderr, ">> Hibas feltetel az if utasitasban\n");
        yyerrok;
    }
    ;

while_utasitas:
    AMIG '(' condition ')' blokk
    | AMIG '(' error ')' blokk {
        fprintf(stderr, ">> Hibas feltetel az amig utasitasban\n");
        yyerrok;
    }
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
    | condition AND condition
    | condition OR condition
    | NOT condition
    | '(' condition ')'
    ;

expression:
    INTEGER {
        $$.isInteger = 1;
        $$.isFloat = 0;
    }
    | FLOAT {
        $$.isInteger = 0;
        $$.isFloat = 1;
    }
    | NEV {
        if (checkDeclared($1, yylineno, column)) {
            $$ = getSymbolType($1);
        } else {
            $$.isInteger = 0;
            $$.isFloat = 0;
        }
        free($1);
    }
    | expression '+' expression {
        checkTypeCompatibility($1, $3, yylineno, column, "osszeadas");
        $$ = $1;
    }
    | expression '-' expression {
        checkTypeCompatibility($1, $3, yylineno, column, "kivonas");
        $$ = $1;
    }
    | expression '*' expression {
        checkTypeCompatibility($1, $3, yylineno, column, "szorzas");
        $$ = $1;
    }
    | expression '/' expression {
        checkTypeCompatibility($1, $3, yylineno, column, "osztas");
        $$ = $1;
    }
    | '(' expression ')' {
        $$ = $2;
    }
    | '-' expression %prec NEG {
        $$ = $2;
    }
    ;

%%

int main() {
    initSymbolTable();

    printf("Szintaktikai es szemantikai elemzes indul...\n\n");

    int result = yyparse();

    if (result == 0) {
        printf("\n=== OK! Sikeres elemzes ===\n");
        printSymbolTable();
    } else {
        printf("\n=== Hiba tortent az elemzes soran ===\n");
        printSymbolTable();
    }

    freeSymbolTable();
    return result;
}

int yyerror(const char *s) {
    fprintf(stderr, "\n[SZINTAKTIKAI HIBA]\n");
    fprintf(stderr, "  Hely: %d. sor, %d. oszlop\n", yylineno, column);
    fprintf(stderr, "  Uzenet: %s\n", s);
    fprintf(stderr, "  Token: '%s'\n", yytext);
    return 0;
}