Date: Fri, 10 May 85 13:54:41 edt
From: Arnold Robbins <gatech!arnold>
Subject: Yacc and Lex for 11/12/84 draft of ANSI C
Newsgroups: mod.sources

Due to popular request on net.lang.c, I am reposting the Yacc and Lex
descriptions of the 11/12/84 draft of ANSI C.  Many people have wanted
this to make it into a grammar for regular C, for their C compilers.

Arnold Robbins
gatech!arnold
--------------------- cut here ----------------------------
#!/bin/sh
# This is a shell archive, meaning:
# 1. Remove everything above the #!/bin/sh line.
# 2. Save the resulting text in a file.
# 3. Execute the file with /bin/sh (not csh) to create the files:
#	README
#	Makefile
#	gram.y
#	scan.l
#	main.c
# This archive created: Fri May 10 13:51:08 1985
# By:	Arnold Robbins (Pr1mebusters!)
export PATH; PATH=/bin:$PATH
echo shar: extracting "'README'" '(1419 characters)'
if test -f 'README'
then
	echo shar: over-writing existing file "'README'"
fi
cat << \SHAR_EOF > 'README'
The files in this directory contain the ANSI C grammar from the Nov 12, 1984
draft of the standard.  Note that a newer draft has come out since then.
I have applied the two bug fixes I have seen reported on the net for this
grammar.

With a little work, this grammar can be made to parse regular C.
I am reposting it, due to popular demand.  Credit for creating this in
the first place goes to my office mate, Jeff Lee, gatech!jeff.

Here is his original note:
> This is the current (Nov 12, 1984) draft of the C grammar in Yacc form
> with a little scanner I wrote in Lex so that you end up with a complete
> program with which you can amaze and befuddle your friends. Or you can
> sit and crank your own output through it to amuse yourself if you have the
> personality of a cumquat(sp?). This contains nothing to handle preprocessor
> stuff nor to handle "#line" directives so you must remove these beforehand
> to allow it to parse the stuff. Also, it bypasses the typedef problem
> by always returning an IDENTIFIER when it encounters anything that looks
> like an IDENTIFIER, but it has a little stub in place where you would put
> your symbol table lookup to determine if it a typedef or not. Other than
> that, this is all yours. Wear it in good health and if anyone asks, just say
> I told you so. Oh, by the way..... this is in 'shar' format, so you know
> what to do.

Arnold Robbins
gatech!arnold
May, 1985
SHAR_EOF
echo shar: extracting "'Makefile'" '(167 characters)'
if test -f 'Makefile'
then
	echo shar: over-writing existing file "'Makefile'"
fi
cat << \SHAR_EOF > 'Makefile'
YFLAGS	= -d
CFLAGS	= -O
LFLAGS	=

SRC	= gram.y scan.l main.c
OBJ	= gram.o scan.o main.o

a.out	: $(OBJ)
	cc $(OBJ)

scan.o	: y.tab.h

clean	:
	rm -f a.out y.tab.h *.o
SHAR_EOF
echo shar: extracting "'gram.y'" '(7344 characters)'
if test -f 'gram.y'
then
	echo shar: over-writing existing file "'gram.y'"
fi
cat << \SHAR_EOF > 'gram.y'
%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELIPSIS RANGE

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start file
%%

primary_expr
	: identifier
	| CONSTANT
	| STRING_LITERAL
	| '(' expr ')'
	| primary_expr '[' expr ']'
	| primary_expr '(' ')'
	| primary_expr '(' argument_expr_list ')'
	| primary_expr '.' identifier
	| primary_expr PTR_OP identifier
	;

argument_expr_list
	: assignment_expr
	| argument_expr_list ',' assignment_expr
	;

postfix_expr
	: primary_expr
	| primary_expr INC_OP
	| primary_expr DEC_OP
	;

unary_expr
	: postfix_expr
	| INC_OP unary_expr
	| DEC_OP unary_expr
	| unary_operator cast_expr
	| SIZEOF unary_expr
	| SIZEOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expr
	: unary_expr
	| '(' type_name ')' cast_expr
	;

multiplicative_expr
	: cast_expr
	| multiplicative_expr '*' cast_expr
	| multiplicative_expr '/' cast_expr
	| multiplicative_expr '%' cast_expr
	;

additive_expr
	: multiplicative_expr
	| additive_expr '+' multiplicative_expr
	| additive_expr '-' multiplicative_expr
	;

shift_expr
	: additive_expr
	| shift_expr LEFT_OP additive_expr
	| shift_expr RIGHT_OP additive_expr
	;

relational_expr
	: shift_expr
	| relational_expr '<' shift_expr
	| relational_expr '>' shift_expr
	| relational_expr LE_OP shift_expr
	| relational_expr GE_OP shift_expr
	;

equality_expr
	: relational_expr
	| equality_expr EQ_OP relational_expr
	| equality_expr NE_OP relational_expr
	;

and_expr
	: equality_expr
	| and_expr '&' equality_expr
	;

exclusive_or_expr
	: and_expr
	| exclusive_or_expr '^' and_expr
	;

inclusive_or_expr
	: exclusive_or_expr
	| inclusive_or_expr '|' exclusive_or_expr
	;

logical_and_expr
	: inclusive_or_expr
	| logical_and_expr AND_OP inclusive_or_expr
	;

logical_or_expr
	: logical_and_expr
	| logical_or_expr OR_OP logical_and_expr
	;

conditional_expr
	: logical_or_expr
	| logical_or_expr '?' logical_or_expr ':' conditional_expr
	;

assignment_expr
	: conditional_expr
	| unary_expr assignment_operator assignment_expr
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expr
	: assignment_expr
	| expr ',' assignment_expr
	;

constant_expr
	: conditional_expr
	;

declaration
	: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';'
	;

declaration_specifiers
	: ssc_specifier
	| ssc_specifier declaration_specifiers
	| type_specifier
	| type_specifier declaration_specifiers
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator
	| declarator '=' initializer
	;

ssc_specifier
	: TYPEDEF
	| EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

type_specifier
	: CHAR
	| SHORT
	| INT
	| LONG
	| SIGNED
	| UNSIGNED
	| FLOAT
	| DOUBLE
	| CONST
	| VOLATILE
	| VOID
	| struct_or_union_specifier
	| enum_specifier
	| TYPE_NAME
	;

struct_or_union_specifier
	: struct_or_union identifier '{' struct_declaration_list '}'
	| struct_or_union '{' struct_declaration_list '}'
	| struct_or_union identifier
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: type_specifier_list struct_declarator_list ';'
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: declarator
	| ':' constant_expr
	| declarator ':' constant_expr
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM identifier '{' enumerator_list '}'
	| ENUM identifier
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: identifier
	| identifier '=' constant_expr
	;

declarator
	: declarator2
	| pointer declarator2
	;

declarator2
	: identifier
	| '(' declarator ')'
	| declarator2 '[' ']'
	| declarator2 '[' constant_expr ']'
	| declarator2 '(' ')'
	| declarator2 '(' parameter_declaration_list ')'
	;

pointer
	: '*'
	| '*' type_specifier_list
	| '*' pointer
	| '*' type_specifier_list pointer
	;

type_specifier_list
	: type_specifier
	| type_specifier_list type_specifier
	;

parameter_declaration_list
	: identifier_list
	| identifier_list ',' ELIPSIS
	| parameter_types
	;

identifier_list
	: identifier
	| identifier_list ',' identifier
	;

parameter_types
	: parameter_list
	| parameter_list ',' ELIPSIS
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: type_specifier_list declarator
	| type_name
	;

type_name
	: type_specifier_list
	| type_specifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| abstract_declarator2
	| pointer abstract_declarator2
	;

abstract_declarator2
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expr ']'
	| abstract_declarator2 '[' ']'
	| abstract_declarator2 '[' constant_expr ']'
	| '(' ')'
	| '(' parameter_types ')'
	| abstract_declarator2 '(' ')'
	| abstract_declarator2 '(' parameter_types ')'
	;

initializer
	: assignment_expr
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| initializer_list ',' initializer
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: identifier ':' statement
	| CASE constant_expr ':' statement
	| CASE constant_expr RANGE constant_expr ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
	;

expression_statement
	: ';'
	| expr ';'
	;

selection_statement
	: IF '(' expr ')' statement
	| IF '(' expr ')' statement ELSE statement
	| SWITCH '(' expr ')' statement
	;

iteration_statement
	: WHILE '(' expr ')' statement
	| DO statement WHILE '(' expr ')' ';'
	| FOR '(' ';' ';' ')' statement
	| FOR '(' ';' ';' expr ')' statement
	| FOR '(' ';' expr ';' ')' statement
	| FOR '(' ';' expr ';' expr ')' statement
	| FOR '(' expr ';' ';' ')' statement
	| FOR '(' expr ';' ';' expr ')' statement
	| FOR '(' expr ';' expr ';' ')' statement
	| FOR '(' expr ';' expr ';' expr ')' statement
	;

jump_statement
	: GOTO identifier ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expr ';'
	;

file
	: external_definition
	| file external_definition
	;

external_definition
	: function_definition
	| declaration
	;

function_definition
	: declarator function_body
	| declaration_specifiers declarator function_body
	;

function_body
	: compound_statement
	| declaration_list compound_statement
	;

identifier
	: IDENTIFIER
	;
%%

#include <stdio.h>

extern char *yytext;
extern int column;

yyerror(s)
char *s;
{
	fflush(stdout);
	printf("\n%*s\n%*s\n", column, "^", column, s);
}
SHAR_EOF
echo shar: extracting "'scan.l'" '(4263 characters)'
if test -f 'scan.l'
then
	echo shar: over-writing existing file "'scan.l'"
fi
cat << \SHAR_EOF > 'scan.l'
D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
LS			(l|L)
US			(u|U)

%{
#include <stdio.h>
#include "y.tab.h"

void count();
%}

%%
"/*"			{ comment(); }

"auto"			{ count(); return(AUTO); }
"break"			{ count(); return(BREAK); }
"case"			{ count(); return(CASE); }
"char"			{ count(); return(CHAR); }
"const"			{ count(); return(CONST); }
"continue"		{ count(); return(CONTINUE); }
"default"		{ count(); return(DEFAULT); }
"do"			{ count(); return(DO); }
"double"		{ count(); return(DOUBLE); }
"else"			{ count(); return(ELSE); }
"enum"			{ count(); return(ENUM); }
"extern"		{ count(); return(EXTERN); }
"float"			{ count(); return(FLOAT); }
"for"			{ count(); return(FOR); }
"goto"			{ count(); return(GOTO); }
"if"			{ count(); return(IF); }
"int"			{ count(); return(INT); }
"long"			{ count(); return(LONG); }
"register"		{ count(); return(REGISTER); }
"return"		{ count(); return(RETURN); }
"short"			{ count(); return(SHORT); }
"signed"		{ count(); return(SIGNED); }
"sizeof"		{ count(); return(SIZEOF); }
"static"		{ count(); return(STATIC); }
"struct"		{ count(); return(STRUCT); }
"switch"		{ count(); return(SWITCH); }
"typedef"		{ count(); return(TYPEDEF); }
"union"			{ count(); return(UNION); }
"unsigned"		{ count(); return(UNSIGNED); }
"void"			{ count(); return(VOID); }
"volatile"		{ count(); return(VOLATILE); }
"while"			{ count(); return(WHILE); }

{L}({L}|{D})*		{ count(); return(check_type()); }

0[xX]{H}+{LS}?{US}?	{ count(); return(CONSTANT); }
0[xX]{H}+{US}?{LS}?	{ count(); return(CONSTANT); }
0{D}+{LS}?{US}?		{ count(); return(CONSTANT); }
0{D}+{US}?{LS}?		{ count(); return(CONSTANT); }
{D}+{LS}?{US}?		{ count(); return(CONSTANT); }
{D}+{US}?{LS}?		{ count(); return(CONSTANT); }
'(\\.|[^\\'])+'		{ count(); return(CONSTANT); }

{D}+{E}{LS}?		{ count(); return(CONSTANT); }
{D}*"."{D}+({E})?{LS}?	{ count(); return(CONSTANT); }
{D}+"."{D}*({E})?{LS}?	{ count(); return(CONSTANT); }

\"(\\.|[^\\"])*\"	{ count(); return(STRING_LITERAL); }

">>="			{ count(); return(RIGHT_ASSIGN); }
"<<="			{ count(); return(LEFT_ASSIGN); }
"+="			{ count(); return(ADD_ASSIGN); }
"-="			{ count(); return(SUB_ASSIGN); }
"*="			{ count(); return(MUL_ASSIGN); }
"/="			{ count(); return(DIV_ASSIGN); }
"%="			{ count(); return(MOD_ASSIGN); }
"&="			{ count(); return(AND_ASSIGN); }
"^="			{ count(); return(XOR_ASSIGN); }
"|="			{ count(); return(OR_ASSIGN); }
">>"			{ count(); return(RIGHT_OP); }
"<<"			{ count(); return(LEFT_OP); }
"++"			{ count(); return(INC_OP); }
"--"			{ count(); return(DEC_OP); }
"->"			{ count(); return(PTR_OP); }
"&&"			{ count(); return(AND_OP); }
"||"			{ count(); return(OR_OP); }
"<="			{ count(); return(LE_OP); }
">="			{ count(); return(GE_OP); }
"=="			{ count(); return(EQ_OP); }
"!="			{ count(); return(NE_OP); }
";"			{ count(); return(';'); }
"{"			{ count(); return('{'); }
"}"			{ count(); return('}'); }
","			{ count(); return(','); }
":"			{ count(); return(':'); }
"="			{ count(); return('='); }
"("			{ count(); return('('); }
")"			{ count(); return(')'); }
"["			{ count(); return('['); }
"]"			{ count(); return(']'); }
"."			{ count(); return('.'); }
"&"			{ count(); return('&'); }
"!"			{ count(); return('!'); }
"~"			{ count(); return('~'); }
"-"			{ count(); return('-'); }
"+"			{ count(); return('+'); }
"*"			{ count(); return('*'); }
"/"			{ count(); return('/'); }
"%"			{ count(); return('%'); }
"<"			{ count(); return('<'); }
">"			{ count(); return('>'); }
"^"			{ count(); return('^'); }
"|"			{ count(); return('|'); }
"?"			{ count(); return('?'); }

[ \t\v\n\f]		{ count(); }
.			{ /* ignore bad characters */ }

%%

yywrap()
{
	return(1);
}

comment()
{
	char c, c1;

loop:
	while ((c = input()) != '*' && c != 0)
		putchar(c);

	if ((c1 = input()) != '/' && c != 0)
	{
		unput(c1);
		goto loop;
	}

	if (c != 0)
		putchar(c1);
}

int column = 0;

void count()
{
	int i;

	for (i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n')
			column = 0;
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
			column++;

	ECHO;
}

int check_type()
{
/*
* pseudo code --- this is what it should check
*
*	if (yytext == type_name)
*		return(TYPE_NAME);
*
*	return(IDENTIFIER);
*/

/*
*	it actually will only return IDENTIFIER
*/

	return(IDENTIFIER);
}
SHAR_EOF
echo shar: extracting "'main.c'" '(48 characters)'
if test -f 'main.c'
then
	echo shar: over-writing existing file "'main.c'"
fi
cat << \SHAR_EOF > 'main.c'
main()
{
	int yyparse();

	return(yyparse());
}
SHAR_EOF
#	End of shell archive
exit 0

