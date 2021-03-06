/* Scanner Program */                                                                                                                           

 /* DEFINITIONS */
D			[0-9]                                                                                                                                                     
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F|l|L)
IS			(u|U|l|L)*

%{
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
int found=0,var_cnt=0,i,nestedComment=0,bracCount=0,lineCount=0,flag=0;
char *comment;
void add_to_comment(char*);
void insert(char *yytext,char type);
struct holder
{
	char *name,token[20];
	int val;
	struct holder *next;
}*st,*head;

%}
string L?\"(\\.|[^\\"])*\"
printf (printf\({string}(\,([^,)])+)*\))
prnterr (printf\(.*\))
scanf (scanf\({string}(\,([^,)])+)*\))
scanerr (scanf\(.*\))
comment (\/\/.*)
comstr (\/\*)
comend (\*\/)
keyword "auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while"
relop >|<|<=|>=|!=
ws [ \t]+
%x C_COMMENT

%%

 /* RULES */
^#([-a-zA-Z0-9.]|{relop}|{ws})* {insert(yytext,'d');}
{printf}            {;}
{prnterr}           {printf("ERROR: printferror\n");}
{scanf}             {;}
{scanerr}           {printf("ERROR: scanferror\n");}                                                                                                 
{comment}           ;

 /*RegEx for Comments*/

{comstr}            {  BEGIN(C_COMMENT);
			           nestedComment++;
                       lineCount++;
                       add_to_comment("\n");
					}
<C_COMMENT>{comstr} { nestedComment++;
                      if(nestedComment>1)
                      {
						printf("ERROR: Nested Comment\n");
                        flag = 1;
                      }
                    }
<C_COMMENT>{comend} {
                        if(nestedComment>0)
                                nestedComment--;
                        else
                            printf("ERROR: */ found before /*\n");
                        if(nestedComment==0)
                            BEGIN(INITIAL);
                    }
<C_COMMENT>\n {lineCount++; add_to_comment("\n");}
<C_COMMENT>. {add_to_comment(yytext);}

 /*RegEx for Keywords*/

{keyword}  {if(nestedComment<=0)
                insert(yytext,'k');
            }

 /*RegEx for Variables*/

{L}({L}|{D})*		{  if(nestedComment<=0) insert(yytext,'v'); }
{D}+{L}+      { printf("ERROR: Bad Token\n");}

 /*RegEx for Constants*/

0[xX]{H}+{IS}?		{if(nestedComment<=0) insert(yytext,'c');}
0{D}+{IS}?		{if(nestedComment<=0) insert(yytext,'c');}
{D}+{IS}?		{if(nestedComment<=0) insert(yytext,'c');}
L?'(\\.|[^\\'])+'	{if(nestedComment<=0) insert(yytext,'c');}
{D}+{E}{FS}?		{if(nestedComment<=0) insert(yytext,'c');}
{D}*"."{D}+({E})?{FS}?	{if(nestedComment<=0) insert(yytext,'c');}
{D}+"."{D}*({E})?{FS}?	{if(nestedComment<=0) insert(yytext,'c');}

 /*RegEx for String Literals*/

L?\"(\\.|[^\\"])*\"	{if(nestedComment<=0) insert(yytext,'s');}
L?\"(\\.|[^\\"])*	{if(nestedComment<=0) printf("ERROR: String does not end\n");}

 /*RegEx for Operators*/

"..."|">>="|"<<="|"+="|"-="|"*="|"/="		{if(nestedComment<=0) insert(yytext,'o');}

"%="|"&="|"^="|"|="|">>"|"<<"|"++"|"--"|"->"|"&&"|"||"|"<="			{if(nestedComment<=0) insert(yytext,'o');}

">="|"=="|"!="		{if(nestedComment<=0) insert(yytext,'o');}

 /*RegEx for Punctuators*/

";"			{if(nestedComment<=0) insert(yytext,'p');}
"{" 		{if(nestedComment<=0) {
                insert(yytext,'p');
                bracCount++;
                }
            }
"<%"		{if(nestedComment<=0) insert(yytext,'p');}
"}" 	   	{if(nestedComment<=0) {
                insert(yytext,'p');
                bracCount--;
                }
            }
"%>"		{if(nestedComment<=0) insert(yytext,'p');}
","			{if(nestedComment<=0) insert(yytext,'p');}
":"			{if(nestedComment<=0) insert(yytext,'p');}
"="			{if(nestedComment<=0) insert(yytext,'p');}
"("			{if(nestedComment<=0) insert(yytext,'p');}
")"			{if(nestedComment<=0) insert(yytext,'p');}
("["|"<:")		{if(nestedComment<=0) insert(yytext,'p');}
("]"|":>")		{if(nestedComment<=0) insert(yytext,'p');}
"."			{if(nestedComment<=0) insert(yytext,'p');}

 /*RegEx for Operators*/

"&"			{if(nestedComment<=0) insert(yytext,'o');}
"!"			{if(nestedComment<=0) insert(yytext,'o');}
"~"			{if(nestedComment<=0) insert(yytext,'o');}
"-"			{if(nestedComment<=0) insert(yytext,'o');}
"+"			{if(nestedComment<=0) insert(yytext,'o');}
"*"			{if(nestedComment<=0) insert(yytext,'o');}
"/"			{if(nestedComment<=0) insert(yytext,'o');}
"%"			{if(nestedComment<=0) insert(yytext,'o');}
"<"			{if(nestedComment<=0) insert(yytext,'o');}                                                                                                    
">"			{if(nestedComment<=0) insert(yytext,'o');}
"^"			{if(nestedComment<=0) insert(yytext,'o');}
"|"			{if(nestedComment<=0) insert(yytext,'o');}
"?"			{if(nestedComment<=0) insert(yytext,'o');}

[ \t\v\n\f]		{;}
.			{ printf("ERROR : Bad Character"); }

%%

/* USER CODE */

int main()
{
 comment = (char*)malloc(100*sizeof(char));
 yyin=fopen("input.c","r");
 yyout=fopen("out.txt","w");
 fprintf(yyout,"\n Symbol Table Format is:\n \tLexeme\t\t\t\t\t\t\t\tToken\t\t\t\t\tAttribute Value\n");
 yylex();
 if(nestedComment!=0)
    printf("ERROR: Comment does not end\n");
 if(bracCount!=0)
    printf("ERROR: Bracket mismatch\n");
 fprintf(yyout,"\n");
 if(flag==1)
 {
   lineCount=0;
   fprintf(yyout,"\n\nComment (%d lines):\n",lineCount);
   fprintf(yyout,"ERROR: Nested Comment");
 }
 else
 {
   fprintf(yyout,"\n\nComment (%d lines):",lineCount);
   fputs(comment,yyout);
 }
 fclose(yyout);
}
int yywrap()
{
 return(1);
}

void add_to_comment(char *yytext)
{
 /* Function to display comments separately! */

 int len1,len2;
 char *temp;                                                                                                                       
 len1 = strlen(comment);
 len2 = strlen(yytext);
 temp = (char*)malloc((len1+1)*sizeof(char));
 strcpy(temp,comment);
 comment = (char*)malloc((len1+len2+1)*sizeof(char));
 strcat(temp,yytext);
 strcpy(comment,temp);
}

void insert(char *yytext,char type)
{
  /* Function to insert symbols to the Symbol Table */

    int len1 = strlen(yytext);
    char token[20];
	struct holder *symbol,*temp,*nextptr;
	nextptr = head;
    switch(type)
    {
        case 'c':
            strcpy(token,"Constant");
            break;
        case 'v':
            strcpy(token,"Variable");
            break;
        case 'p':
            strcpy(token,"Punctuator");
            break;
        case 'o':
            strcpy(token,"Operator");
            break;
        case 'k':
            strcpy(token,"Keyword");
            break;
        case 's':
            strcpy(token,"String Literal");
            break;
        case 'd':
            strcpy(token,"Preprocessor Statement");
            break;
    }
    if(nestedComment<=0)
    {
        for(i=0;i<var_cnt;i++,nextptr=nextptr->next)
		{
			symbol = nextptr;
            if(strcmp(symbol->name,yytext)==0)
                break;                                                                                                
		}
        if(i==var_cnt)
        {
			temp = (struct holder*)malloc(sizeof(struct holder));
            temp->name = (char*)malloc((len1+1)*sizeof(char));
			strcpy(temp->name,yytext);
            strcpy(temp->token,token);
			temp->val = i;
			temp->next = NULL;
			if(var_cnt==0)
				head = temp;
			else
				symbol->next = temp;
			var_cnt++;
        }
        fprintf(yyout,"\n%20s%30.30s%20d",yytext,token,i);
    }
}                                                                                                           
