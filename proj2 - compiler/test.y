%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "node.h"
int yylex(void);
int yyerror(const char*);

NProgram *program;

node2Type *fac(int i, int v);
node2Type *fac1(NExpression *exp);
node2Type *trm(NFactor *fac1, int op, NFactor *fac2);
node2Type *trm1(NFactor *fac1);
node2Type *sxp(NTerm *trm1, int op, NTerm *trm2);
node2Type *sxp1(NTerm *trm1);
node2Type *xp(NSimpleExpression *sxp1, int op, NSimpleExpression *sxp2);
node2Type *xp1(NSimpleExpression *sxp1);
node2Type *wi(NExpression *exp1);
node2Type *whl(NExpression *exp, NStmtSq *smq);
node2Type *els(NStmtSq *smq);
node2Type *els1();
node2Type *ifs(NExpression *exp, NStmtSq *smq, NElseClause *els);
node2Type *ass(int i, NExpression *exp);
node2Type *ass1(int i);
node2Type *st(NAssignment *asg);
node2Type *st1(NIfStmt *ifs);
node2Type *st2(NWhileStmt *wl);
node2Type *st3(NWriteInt *wi);
node2Type *stsq(NStatement *st, NStmtSq *stmq);
node2Type *stsq1();
node2Type *typ(typeEnum t);
node2Type *dec(int ide, NType *t, NDeclaration *nd);
node2Type *dec1();

int sym[26];
%}

%error-verbose

%code requires { #include "node.h" }

%union
{
  char *sval;
  int ival;
  NFactor *factor;
  NTerm *term;
  NSimpleExpression *sxp;
  NExpression *xp;
  NWriteInt *wrtint;
  NStatement *stmt;
  NStmtSq *stmtsq;
  NWhileStmt *whileStmt;
  NElseClause *elseClause;
  NIfStmt *ifStmt;
  NAssignment *asgn;
  NType *type;
  NDeclaration *decl;
};

%token NUMBER
%token OP2 OP3 OP4
%token ASGN IDENT
%token LEFT_PARENTHESIS RIGHT_PARENTHESIS
%token BGN END
%token IF THEN ELSE WHILE DO
%token PROGRAM
%token VAR AS INT BOOL SC
%token WRITEINT READINT

%type <decl> Declaration
%type <stmtsq> StmtSq
%type <stmt> Statement
%type <type> Type
%type <xp> Expression
%type <sxp> SimpleExpression
%type <term> Term
%type <factor> Factor
%type <elseClause> ElseClause
%type <int> IDENT OP2 OP3 OP4 NUMBER BOOL

%type <asgn> Assignment
%type <ifStmt> IfStmt
%type <whileStmt> WhileStmt
%type <wrtint> WriteInt

%start Program
%%

Program:
  PROGRAM Declaration BGN StmtSq END { }
  ;

Declaration:
  VAR IDENT AS Type SC Declaration { $$ = dec($2, $4, $6); } //need to push Declaration but keep Type static ?
  | { $$ = dec1(); }
  ;

Type:
  INT { $$ = typ(typeInt); }
  | BOOL { $$ = typ(typeBool); }
  ;

StmtSq:
  Statement SC StmtSq { $$ = stsq($1, $3);}
  | { $$ = stsq1(); }
  ;

Statement:
  Assignment { $$ = st($1); }
  | IfStmt { $$ = st1($1); }
  | WhileStmt { $$ = st2($1); }
  | WriteInt { $$ = st3($1); }
  ;

Assignment:
  IDENT ASGN Expression { $$ = ass($1, $3); }
  | IDENT ASGN READINT { $$ = ass1($1); }
  ;

IfStmt:
  IF Expression THEN StmtSq ElseClause END { $$ = ifs($2, $4, $5) }
  ;

ElseClause:
  ELSE StmtSq { $$ = els($2); }
  | { $$ = els1(); }
  ;

WhileStmt:
  WHILE Expression DO StmtSq END { $$ = whl($2, $4); }
  ;

WriteInt:
  WRITEINT Expression { $$ = wi($2); }
  ;

Expression:
  SimpleExpression { $$ = xp1($1); }
  | SimpleExpression OP4 SimpleExpression { $$ = xp($1, $2, $3); }
  ;

SimpleExpression:
  Term OP3 Term { $$ = sxp($1, $2, $3); }
  | Term { $$ = sxp1($1); }
  ;

Term:
  Factor OP2 Factor { $$ = trm($1, $2, $3); }
  | Factor { $$ = trm1($1); }
  ;

Factor:
  IDENT { $$ = fac($1, -1); }
  | NUMBER { $$ = fac(-1, $1); }
  | BOOL { $$ = fac(-1, $1); }
  | LEFT_PARENTHESIS Expression RIGHT_PARENTHESIS { $$ = fac1($2); }
  ;

%%
int yyerror(const char *s){
  printf("yyerror: %s\n", s);
}
int main(void){
  yyparse();
}
int yywrap(){

}

node2Type *fac(int i, int v) {
  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->nodeType = typeFactor;

  NFactor *f;
  if((f = malloc(sizeof(NFactor))) == NULL){
    yyerror("out of memory");
  }
  if(i>0){
    //change so id stores based on if already inside
    f->id = i;
  }
  if(v>0){
    f->val = v;
  }

  n->fac = f;
  return n;
}

node2Type *fac1(...) {
  va_list ap;
  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->nodeType = typeFactor;

  NFactor *f;
  if((f = malloc(sizeof(NFactor))) == NULL){
    yyerror("out of memory");
  }

  va_start(ap, 1);
  f->xp = va_arg(ap, NExpression*);
  va_end(ap);
  
  n->fac = f;
  return n;
}

node2Type *trm(NFactor *fac1, int op, NFactor *fac2){
  NTerm *t;
  if((t = malloc(sizeof(NTerm))) == NULL){
    yyerror("out of memory");
  }
  t->f1 = fac1;
  t->opr = op;
  t->f2 = fac2;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->trm = t;
  n->nodeType = typeTerm;
  return n;
}

node2Type *trm1(NFactor *fac1){
  NTerm *t;
  if((t = malloc(sizeof(NTerm))) == NULL){
    yyerror("out of memory");
  }
  t->f1 = fac1;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->trm = t;
  n->nodeType = typeTerm;
  return n;
}

node2Type *sxp(NTerm *trm1, int op, NTerm *trm2){
  NSimpleExpression *sx;
  if((sx = malloc(sizeof(NSimpleExpression))) == NULL){
    yyerror("out of memory");
  }
  sx->t1 = trm1;
  sx->opr = op;
  sx->t2 = trm2;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->sxp = sx;
  n->nodeType = typeSimpleExpression;
  return n;
}

node2Type *sxp1(NTerm *trm1){
  NSimpleExpression *sx;
  if((sx = malloc(sizeof(NSimpleExpression))) == NULL){
    yyerror("out of memory");
  }
  sx->t1 = trm1;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->sxp = sx;
  n->nodeType = typeSimpleExpression;
  return n;
}

node2Type *xp(NSimpleExpression *sxp1, int op, NSimpleExpression *sxp2){
  NExpression *exp;
  if((exp = malloc(sizeof(NExpression))) == NULL){
    yyerror("out of memory");
  }
  exp->sx1 = sxp1;
  exp->opr = op;
  exp->sx2 = sxp2;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->exp = exp;
  n->nodeType = typeExpression;
  return n;
}

node2Type *xp1(NSimpleExpression *sxp1){
  NExpression *exp;
  if((exp = malloc(sizeof(NExpression))) == NULL){
    yyerror("out of memory");
  }
  exp->sx1 = sxp1;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->exp = exp;
  n->nodeType = typeExpression;
  return n;
}

node2Type *wi(NExpression *exp1){
  NWriteInt *wrt;
  if((wrt = malloc(sizeof(NWriteInt))) == NULL){
    yyerror("out of memory");
  }
  wrt->xp1 = exp1;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->wri = wrt;
  n->nodeType = typeWriteInt;
  return n;
}

node2Type *whl(NExpression *exp, NStmtSq *smq){
  NWhileStmt *wl;
  if((wl = malloc(sizeof(NWhileStmt))) == NULL){
    yyerror("out of memory");
  }
  wl->xp = exp;
  wl->stmtsq = smq;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->whi = wl;
  n->nodeType = typeWhileStmt;
  return n;
}

node2Type *els(NStmtSq *smq){
  NElseClause *el;
  if((el = malloc(sizeof(NElseClause))) == NULL){
    yyerror("out of memory");
  }
  el->stmtsq = smq;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->els = el;
  n->nodeType = typeElseClause;
  return n;
}

node2Type *els1(){
  NElseClause *el;
  if((el = malloc(sizeof(NElseClause))) == NULL){
    yyerror("out of memory");
  }
  el->stmtsq = NULL;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->els = el;
  n->nodeType = typeElseClause;
  return n;
}

node2Type *ifs(NExpression *exp, NStmtSq *smq, NElseClause *els){
  NIfStmt *ifst;
  if((ifst = malloc(sizeof(NIfStmt))) == NULL){
    yyerror("out of memory");
  }
  ifst->xp = exp;
  ifst->stmtsq = smq;
  ifst->elseClause = els;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->ifs = ifst;
  n->nodeType = typeIfStmt;
  return n;
}

node2Type *ass(int i, NExpression *exp){
  NAssignment *assgn;
  if((assgn = malloc(sizeof(NAssignment))) == NULL){
    yyerror("out of memory");
  }
  assgn->xp = exp;
  //change so id stores based on if already inside
  assgn->id = i;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->asg = assgn;
  n->nodeType = typeAssignment;
  return n;
}

node2Type *ass1(int i){
  NAssignment *assgn;
  if((assgn = malloc(sizeof(NAssignment))) == NULL){
    yyerror("out of memory");
  }
  //change so id stores based on if already inside
  assgn->id = i;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->asg = assgn;
  n->nodeType = typeAssignment;
  return n;
}

node2Type *st(NAssignment *asg){
  NStatement *stm;
  if((stm = malloc(sizeof(NStatement))) == NULL){
    yyerror("out of memory");
  }
  stm->asgn1 = asg;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->stm = stm;
  n->nodeType = typeStatement;
  return n;
}

node2Type *st1(NIfStmt *ifs){
  NStatement *stm;
  if((stm = malloc(sizeof(NStatement))) == NULL){
    yyerror("out of memory");
  }
  stm->ifstmt1 = ifs;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->stm = stm;
  n->nodeType = typeStatement;
  return n;
}

node2Type *st2(NWhileStmt *wl){
  NStatement *stm;
  if((stm = malloc(sizeof(NStatement))) == NULL){
    yyerror("out of memory");
  }
  stm->whilestmt1 = wl;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->stm = stm;
  n->nodeType = typeStatement;
  return n;
}

node2Type *st3(NWriteInt *wi){
  NStatement *stm;
  if((stm = malloc(sizeof(NStatement))) == NULL){
    yyerror("out of memory");
  }
  stm->wrtint1 = wi;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->stm = stm;
  n->nodeType = typeStatement;
  return n;
}

node2Type *stsq(NStatement *st, NStmtSq *stmq){
  NStmtSq *sq;
  if((sq = malloc(sizeof(NStmtSq))) == NULL){
    yyerror("out of memory");
  }
  sq->stmt = st;
  sq->next = stmq;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->ssq = sq;
  n->nodeType = typeStmtSq;
  return n;
}

node2Type *stsq1(){
  NStmtSq *sq;
  if((sq = malloc(sizeof(NStmtSq))) == NULL){
    yyerror("out of memory");
  }
  sq->stmt = NULL;
  sq->next = NULL;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->ssq = sq;
  n->nodeType = typeStmtSq;
  return n;
}

node2Type *typ(typeEnum t){
  NType *ty;
  if((ty = malloc(sizeof(NType))) == NULL){
    yyerror("out of memory");
  }
  ty->type = t;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->typ = ty;
  n->nodeType = typeType;
  return n;
}

node2Type *dec(int ide, NType *t, NDeclaration *nd){
  NDeclaration *d;
  if((d = malloc(sizeof(NDeclaration))) == NULL){
    yyerror("out of memory");
  }
  d->type = t;
  idNodeType *iden;
  if((iden = malloc(sizeof(idNodeType))) == NULL){
    yyerror("out of memory");
  }
  iden->type = typeId;
  iden->i = ide;
  d->id = iden;
  d->next = nd;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->dec = d;
  n->nodeType = typeDeclaration;
  return n;
}

node2Type *dec1(){
  NDeclaration *d;
  if((d = malloc(sizeof(NDeclaration))) == NULL){
    yyerror("out of memory");
  }
  d->type = NULL;
  //change so id stores based on if already inside
  d->id = NULL;
  d->next = NULL;

  node2Type *n;
  if((n = malloc(sizeof(node2Type))) == NULL){
    yyerror("out of memory");
  }
  n->dec = d;
  n->nodeType = typeDeclaration;
  return n;
}