
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<stdarg.h>

typedef enum { typeCon, typeScon, typeOp, typeVar } Types;
typedef enum { vFunc, vInt, vChar, vNull, vPointer } Vtype;

typedef struct {
	union {
		long long int val;
		char *strVal;
	};
} conType;

typedef struct {
	char *name;
	int type;
	int  symoff;
	void *extra;
} varType;


typedef struct {
	int  op;
	int  nops;
	char *flabel;
	void **operands;
} operType; 

struct Node {
	Types type;
	int reg;		/* register where this is mapped */
	int sfof;		/* stack frame offset */
	int hits;
	int dirty;
	union {
		conType con;
		varType var;
		operType oper;
	};
};

struct Node *create_scon(char *str);

struct Node *create_con(long long int val);

struct Node *sym_lookup(char *name);

void insert_symtab(struct Node *n);

char *new_cstr(char *str);

struct Node *create_var(char *name, int type, void*);

struct Node *create_oper(int type, int nops, ...);

void display_tree(struct Node* root);

void add_child(struct Node *parent, struct Node *child);
