%{
   #include<stdio.h>
   #include<string.h>
   void yyerror(const char *msg);
   extern int currLine;
   int myError = 0;
   int otherError = 0;
   
   char *identToken;
   int numberToken;
   int productionID = 0;

   char list_of_function_names[100][100];
   int  count_names = 0;

//#define YYDEBUG 1
//yydebug=1;
%}

%union {
  char *op_val;
}

%define parse.error verbose
%type <op_val> var
%type <op_val> ident
%type <op_val> expression
%type <op_val> multiplicative_expression
%type <op_val> term
%start prog_start
%token BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token FUNCTION RETURN MAIN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token INTEGER ARRAY OF
%token IF THEN ENDIF ELSE
%token WHILE DO BEGINLOOP ENDLOOP  CONTINUE
%token READ WRITE
%token AND OR NOT TRUE FALSE
%token SUB ADD MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN ASSIGN
%token <op_val> NUMBER 
%token <op_val> IDENT

%%

prog_start: 
	functions
		{};

functions: 
	/* epsilon */
		{}
	| function functions
		{};

function: function_ident
	SEMICOLON
	BEGIN_PARAMS declarations END_PARAMS
	BEGIN_LOCALS declarations END_LOCALS
	BEGIN_BODY statements end_body 
{

};

end_body: END_BODY {
   printf("endfunc\n");
}

function_ident: FUNCTION ident {

     char *token = identToken;
     printf("func %s\n", token);

     printf(". _temp\n");

     strcpy(list_of_function_names[count_names], token);
     count_names++;
}



ident:
	IDENT
		{ $$ = $1; };

declarations: 
	/* epsilon */
		{}
	| declaration SEMICOLON declarations
		{};

declaration: 
	IDENT COLON INTEGER
{

       char *token = $1;
       printf(". %s\n", token);

}
	| IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
		{};

statement: 
	var ASSIGN expression
{
     

  char *dest = $1;
  char *src  = $3;
  printf("= %s, %s\n", dest, src);

}
	| IF bool_exp THEN statements ENDIF
		{}
	| IF bool_exp THEN statements ELSE statements ENDIF
		{}
	| WHILE bool_exp 
{

    // beginning of the loop
    //printf("begining of loop\n");
    printf(": loop_label\n");
    printf("?:= loop_body, %s\n", "1");
    printf(":= loop_end\n");
    printf(": loop_body\n");
}
          BEGINLOOP statements
{
    // loop body.
} ENDLOOP
{
   // end of the loop
   printf(":= loop_label\n");
   printf(": loop_end\n");
}
	| DO BEGINLOOP statements ENDLOOP WHILE bool_exp
		{}
	| READ vars
		{}
	| WRITE IDENT
{

  printf(".> %s\n", $2);

}
	| CONTINUE
		{}
	| RETURN expression
		{};
	
statements: 
	statement SEMICOLON/* epsilon */
		{}
	| statement SEMICOLON statements
		{};

expression: 
	multiplicative_expression
{$$ = $1; }
	| multiplicative_expression ADD expression
{     
  char *src1 =  $1;
  char *src2 =  $3;
  char *dest = "_temp";
  printf("+ %s, %s, %s\n", dest, src1, src2);
  $$ = dest;
}
	| multiplicative_expression SUB expression
{

  char *src1 =  $1;
  char *src2 =  $3;
  char *dest = "_temp";
  printf("- %s, %s, %s\n", dest, src1, src2);
  $$ = dest;


};

multiplicative_expression: 
	term
		{ $$ = $1; }
	| term MULT multiplicative_expression
		{ $$ = "SLDKFJDSLKJ"; }
	| term DIV multiplicative_expression
		{ $$ = "SLDKFJDSLKJ"; }
	| term MOD multiplicative_expression
		{ $$ = "SLDKFJDSLKJ"; }
		;

term: 
	var
		{ $$ = $1; }
	| SUB var
		{ $$ = "SLDKFJDSLKJ"; }
	| NUMBER
		{ $$ = $1; }
	| SUB NUMBER
		{ $$ = "SLDKFJDSLKJ"; }
	| L_PAREN expression R_PAREN
		{ $$ = "SLDKFJDSLKJ"; }
	| SUB L_PAREN expression R_PAREN
		{ $$ = "SLDKFJDSLKJ"; }
	| ident L_PAREN expressions R_PAREN
		{ $$ = "SLDKFJDSLKJ"; };

expressions: 
	/* epsilon */
		{}
	| comma_sep_expressions
		{};

comma_sep_expressions: 
	expression
		{}
	| expression COMMA comma_sep_expressions
		{};

bool_exp:
	relation_and_exp
		{}
	| relation_and_exp OR bool_exp
		{};

relation_and_exp:
	relation_exp
		{}
	| relation_exp AND relation_and_exp
		{};

relation_exp:
	expression comp expression
		{}
	| NOT expression comp expression
		{}
	| TRUE
		{}
	| NOT TRUE
		{}
	| FALSE
		{}
	| NOT FALSE
		{}
	| L_PAREN bool_exp R_PAREN
		{}
	| NOT L_PAREN bool_exp R_PAREN
		{};

comp:
	EQ
		{}
	| NEQ
		{}
	| LT
		{}
	| GT
		{}
	| LTE
		{}
	| GTE
		{};

var:  ident
{ 
    $$ = $1; 

}

	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET
		{ $$ = 0;  /*garbage */};
vars:
	var
		{}
	| var COMMA vars
		{};
	

%%

int main(int argc, char **argv)
{
   yyparse();
   /*int i =0;
   for(i =0; i < count_names; i++ ) {
     printf("%s\n", list_of_function_names[i]);
   }*/

   return 0;
}

void yyerror(const char *msg)
{
   if(myError == 0)
   {
      printf("** Line %d: %s\n", currLine, msg);
      otherError = 1;
   }
   else
   {
      if(otherError == 1)
      {
         printf("   (%s)\n", msg);
         otherError = 0;
      }
   }
   myError = 0;
}
