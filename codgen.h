
#define varname(x)	((struct Node*)x)->var.name
#define nops(x)		((struct Node*)x)->oper.nops
#define ops(x)		((struct Node*)x)->oper.operands
#define opat(x, n)	((struct Node*)(((struct Node*)x)->oper.operands)[0])

#define SLABEL 1
#define LPLABEL 2
#define TLABEL 3

#define VMEM    1
#define VREG    2
#define VANY    3

#define ANYREG  (-1)


void gencode(struct Node *n);

char *genlabel(int type);

char *new_cstr(char *);

int make_var_ready(struct Node *n, int required_pos, int reg);

int get_a_reg(int regno);

int get_var_pos(struct Node *n);

void haparams(struct Node *n);

void hcall(struct Node *n);

void hfunc(struct Node *n);

void hstatements(struct Node *n);

void hLT(struct Node *n);

void hfor(struct Node *n);

int make_var_ready(struct Node *n, int required_pos, int reg);

int get_a_reg(int regno);

int get_var_pos(struct Node *n);

void hif(struct Node *n);

void hEQ(struct Node *n);

void get_rodata(struct Node *n);

void gencode(struct Node *n);

