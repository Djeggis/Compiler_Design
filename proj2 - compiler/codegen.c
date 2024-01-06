#include <stdio.h>
#include "node.h"
#include "test.tab.h"
int ex(node2Type *p) {
	if (!p) return 0;
	switch(p->nodeType) {
		/*case typeCon:
			printf("\tpush\t%d\n", p->con.value);
		break;*/
		case typeId:
			printf("\tpush\t%c\n", p->id.i + 'a');
		break;
        case typeType:
            if(p->typ->type == typeInt) {
                printf("\tpush\tint\n");
            } 
            else{
                printf("\tpush\tbool\n");
            }
        break;
        case typeStmtSq:
            //if have 2 arguments
            if(p->ssq != NULL && p->ssq->stmt != NULL){
                ex(p->ssq->stmt);
                printf("\tpush\t"); //push statement onto stack
                ex(p->ssq->next);
            }
        break;
        case typeStatement:
            ex(p->stm);
            break;
        case typeAssignment:
            //push expression if 1 argument
            if(p->asg->xp != NULL){
                ex(p->asg->xp);
                printf("\tpush\t"); //push expression onto stack
            }
            //else
            else{
                printf("\tpop (assignment?)\n"); //pop assignment based on id
            }
            break;
        case typeIfStmt:
            //push expression
            ex(p->ifs->xp);
            printf("\tpush expression\n");
            //push stmtsq
            ex(p->ifs->stmtsq);
            printf("\tpush stmtsq\n");
            //push elseclause
            ex(p->ifs->elseClause);
            printf("\tpush elseclause\n");
            break;
        case typeElseClause:
            //push stmtsq if 1 argument
            if(p->els->stmtsq != NULL){
                ex(p->els->stmtsq);
                printf("\tpush\t"); //push stmtsq onto stack
            }
            //else
            else{
                printf("\tpop (elseclause?)\n"); //pop elseclause off
            }
            break;
        case typeWhileStmt:
            //push expression
            ex(p->whi->xp);
            printf("\tpush expression\n");
            //push stmtsq
            ex(p->whi->stmtsq);
            printf("\tpush stmtsq\n");
            break;
        case typeWriteInt:
            //push expression
            ex(p->wri->xp1);
            printf("\tpush expression\n");
            break;
        case typeExpression:
            //if 2 arg push 2 simplexp and print op
            if(p->exp->opr != NULL && p->exp->sx2 != NULL){
                ex(p->exp->sx1);
                printf("\tpush simpleexpression\n");
                printf("\t[INSERT OP4 HERE]\n");
                ex(p->exp->sx2);
                printf("\tpush simpleexpression\n");
            }
            //else only one arg push simple xp
            else if(p->exp->sx1 != NULL){
                ex(p->exp->sx1);
                printf("\tpush simpleexpression\n");
            }
            break;
        case typeSimpleExpression:
            //if 2 arg push 2 term and print op
            if(p->sxp->opr != NULL && p->sxp->t2 != NULL){
                ex(p->sxp->t1);
                printf("\tpush term\n");
                printf("\t[INSERT OP3 HERE]\n");
                ex(p->sxp->t2);
                printf("\tpush term\n");
            }
            //else if only one arg push term
            else if(p->sxp->t1 != NULL){
                ex(p->sxp->t1);
                printf("\tpush term\n");
            }
            break;
        case typeTerm:
            //if 2 arg push 2 factor and print op
            if(p->trm->f2 != NULL){
                ex(p->trm->f1);
                printf("\tpush factor\n");
                printf("\t[INSERT OP2 HERE]\n");
                ex(p->trm->f2);
                printf("\tpush factor\n");
            }
            //else if only one arg push factor
            else if(p->trm->f1 != NULL){
                ex(p->trm->f1);
                printf("\tpush factor\n");
            }
            break;
        case typeFactor:
            //push regardless, determine type
            if(p->fac->xp != NULL){
                ex(p->fac->xp);
                printf("\tpush\n"); //push expression
            }
            else if(p->fac->id != NULL){
                ex(p->fac->id);
                printf("\tpush\n"); //push id
            }
            else if(p->fac->val > 0){
                printf("\tpop [VALUE HERE]\n"); //pop value
            }
            break;
        default:
            break;
    }
}