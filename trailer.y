%%

int yyerror(char *x) {
	printf("Illegal C program\nERROR:%s",x);
}

int main(int argc, char *argv[]) {

	if(argc == 2) {
		if(!strcmp("-tree", argv[1])) {
			showtree = 1;
		}
	}

	printf("\nEnter a C Code :\n\n");
        yyparse();

	//system("mv "__rodata__" test.s");
	//system("cat "__textdata__" >> test.s");
	//system("rm "__textdata__);
}


struct Node *create_scon(char *val) {
        struct Node *n;

        if((n = (struct Node*)malloc(sizeof(struct Node))) == NULL) {
                printf("malloc fail\n");
                exit(0);
        }
        n->type = typeScon;
        n->con.strVal = val;
        return n;
}

struct Node *create_con(long long int val) {
        struct Node *n;

        if((n = (struct Node*)malloc(sizeof(struct Node))) == NULL) {
                printf("malloc fail\n");
                exit(0);
        }
        n->type = typeCon;
        n->con.val = val;
        return n;
}


#include "symtab.h"

char *new_cstr(char *str) {
        char *n = (char*)malloc(sizeof(char) * (strlen(str)+1));
        strcpy(n, str);
        return n;
}

void set_type(struct Node *n, int type) {
}

struct Node *create_var(char *name, int type, void *extra) {

        struct Node *n;

        if((n = sym_lookup(name))) {
                return n;
        }

        if((n = (struct Node*)malloc(sizeof(struct Node))) == NULL) {
                printf("malloc failed\n");
                exit(0);
        }

        n->type = typeVar;
        n->var.type = typeVar;
        n->var.name = new_cstr(name);
	n->var.extra = extra;
	n->hits = 0;
	n->reg = ANYREG;
	n->sfof = stack_pointer;
	stack_pointer += 4;			/* assume 4 byte size */
        insert_symtab(n);
        return n;
}

struct Node *create_oper(int type, int nops, ...) {
        struct Node *n;
        int i;
        va_list ap;

        if((n = (struct Node*)malloc(sizeof(struct Node))) == NULL) {
                printf("malloc failed\n");
                exit(0);
        }
        n->type = typeOp;
        n->oper.op = type;
        n->oper.nops = nops;
        n->oper.operands = malloc(sizeof(struct Node*) * nops);

        va_start(ap, nops);
        for (i = 0; i < nops; i++) {
                n->oper.operands[i] = (void*)va_arg(ap, struct Node*);
        }

        va_end(ap);
        return n;
}

int depth, _pline_buffer_init__=0;
void print_tree(struct Node *, int);

char _pline_buffer__[512];

void display_tree(struct Node *root) {
	int i;
	depth = 0;
	if(_pline_buffer_init__==0) {
		for(i=0; i<512; i++) {
			_pline_buffer__[i] = ' ';
		}
		_pline_buffer_init__ = 1;
	}
	print_tree(root, 1);
	printf("\n\n");
}

#ifndef LINEHEIGHT
#define LINEHEIGHT 1
#endif

void print_tree(struct Node* root, int last)
{

	if(depth == 0) {
		printf("\n\n");
	}

        int tab,  i;

	for(i=0; i<LINEHEIGHT; i++) {
	        for( tab=0; tab<depth; tab++ ) {
			printf("%c     ", _pline_buffer__[tab]);
	        }
		if(i == 0) {
			printf("|\n");
		}
	}
	printf("%c-----", last?'+':'|');

	if(!root) {
		puts("(nil.)");
		return;
	}

	++depth;
	_pline_buffer__[depth] = '|';

	if( root->type == typeCon ) {
		printf("[constant { value : %lld } ]\n", root->con.val);
	}

        if( root->type == typeOp ) {

		printf("[node: %s ]\n", NODETYPES[root->oper.op]);

		for(i=root->oper.nops-1; i > -1; i--) {
			if(i == 0) {
				_pline_buffer__[depth] = ' ';
			}
			print_tree((struct Node*)root->oper.operands[i], !i);
		}
	}

	if( root->type == typeVar ) {
		printf("[variable { name : %s, symoff : %d} ]\n", root->var.name, root->var.symoff);
        }
	if( root->type == typeScon ) {
		printf("[string-literal {value : %s} ]\n", root->con.strVal);
	}
	--depth;
}

void add_child(struct Node *parent, struct Node *child) {

	void **newn;
	int i;

	if(parent->type != typeOp) return;

	newn = malloc(sizeof(struct Node*) * (parent->oper.nops+1));
	if(!newn) return;

	for(i=0; i<parent->oper.nops; i++) {
		newn[i] = parent->oper.operands[i];
	}
	newn[i] = child;
	parent->oper.nops++;
	free(parent->oper.operands);
	parent->oper.operands = newn;
}

