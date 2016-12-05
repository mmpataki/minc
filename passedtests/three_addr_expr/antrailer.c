#include "codgen.h"

struct Node *stk[100];
int st = -1;


int push(struct Node *n) {
	stk[++st] = n;
}

int pop() {
	st--;
	return st+1;
}

int genl(char *lab) {
	static int lno=0;
	sprintf(lab, "temp%d", lno++);
}

int codg(char oper) {

	struct Node *arg2 = stk[pop()];
	struct Node *arg1 = stk[pop()];
	struct Node *res  = NULL;

	char lab[10], args1[10], args2[10];

	if(arg2->type == typeCon) sprintf(args2, "%lld", arg2->con.val);
	else			  sprintf(args2, "%s", arg2->var.name);

	
	if(arg1->type == typeCon) sprintf(args1, "%lld", arg1->con.val);
	else			  sprintf(args1, "%s", arg1->var.name);
	

	if(oper == '=') {
		fprintf(stderr, "%s \t = \t %s\n", args1, args2);
	}
	else {
		genl(lab);
		res = create_var(lab, vNull, NULL);
		fprintf(stderr, "%s \t = \t %s \t %c \t %s\n", lab, args1, oper, args2);
	}

	push(res);

}

