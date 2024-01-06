#ifndef NODE_H
#define NODE_H

typedef enum {
    typeInt,
    typeBool
} typeEnum;

typedef enum { typeCon, typeId, typeOpr } nodeEnum;

typedef enum {
    typeCon, 
    typeId,
    typeDeclaration,
    typeType,
    typeStmtSq,
    typeStatement,
    typeAssignment,
    typeIfStmt,
    typeElseClause,
    typeWhileStmt,
    typeWriteInt,
    typeExpression,
    typeSimpleExpression,
    typeTerm,
    typeFactor
} node2Enum;

/* constants */
typedef struct {
        nodeEnum type; /* type of node */
	int value; /* value of constant */
} conNodeType;

/* identifiers */
typedef struct {
	nodeEnum type; /* type of node */
	int i; /* subscript to ident array */
} idNodeType;

/* operators */
typedef struct {
	nodeEnum type; /* type of node */
	int oper; /* operator */
	int nops; /* number of operands */
	union nodeTypeTag *op[1]; /* operands (expandable) */
} oprNodeType;

typedef union nodeTypeTag {
	nodeEnum type; /* type of node */
	conNodeType con; /* constants */
	idNodeType id; /* identifiers */
	oprNodeType opr; /* operators */
} nodeType;

extern int sym[26];

//for some reason, predefining still doesn't allow C header file to
//recognize the structs for usage
typedef struct NFactor;
typedef struct NTerm;
typedef struct NSimpleExpression;
typedef struct NExpression;
typedef struct NWriteInt;
typedef struct NStatement;
typedef struct NStmtSq;
typedef struct NWhileStmt;
typedef struct NElseClause;
typedef struct NIfStmt;
typedef struct NAssignment;
typedef struct NType;
typedef struct NDeclaration;
typedef struct NProgram;
/////////////////////////////////////////////////////

typedef struct {
    NExpression *xp;
    idNodeType *id;
    int val;
} NFactor;

typedef struct {
    NFactor *f1;
    int opr;
    NFactor *f2;
} NTerm;

typedef struct {
    NTerm *t1;
    int opr;
    NTerm *t2;
} NSimpleExpression;

typedef struct {
    NSimpleExpression *sx1;
    int opr;
    NSimpleExpression *sx2;
} NExpression;

typedef struct {
    NExpression *xp1;
}NWriteInt;

typedef struct {
    NAssignment *asgn1;
    NWriteInt *wrtint1;
    NIfStmt *ifstmt1;
    NWhileStmt *whilestmt1;
} NStatement;

typedef struct {
    NStatement *stmt;
    NStmtSq *next;
} NStmtSq;

typedef struct {
    NExpression *xp;
    NStmtSq *stmtsq;
} NWhileStmt;

typedef struct {
    NStmtSq *stmtsq;
} NElseClause;

typedef struct {
    NExpression *xp;
    NStmtSq *stmtsq;
    NElseClause *elseClause;
} NIfStmt;

typedef struct {
    NExpression *xp;
    idNodeType id;
} NAssignment;

typedef struct {
    typeEnum type;
} NType;

typedef struct{
    NType *type;
    idNodeType *id;
    NDeclaration *next;
} NDeclaration;

typedef struct {
    NDeclaration *decl;
    NStmtSq *stmtsq;
} NProgram;

typedef struct {
    node2Enum nodeType;
    NDeclaration *dec;
    NType *typ;
    NStmtSq *ssq;
    NStatement *stm;
    NAssignment *asg;
    NIfStmt *ifs;
    NElseClause *els;
    NWhileStmt *whi;
    NWriteInt *wri;
    NExpression *exp;
    NSimpleExpression *sxp;
    NTerm *trm;
    NFactor *fac;
    conNodeType con; /* constants */
	idNodeType id; /* identifiers */
    oprNodeType opr; /* operators */
} node2Type;

#endif