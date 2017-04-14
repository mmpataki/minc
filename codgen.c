#include "codgen.h"


char *regnames[] = { "eax", "ebx","ecx", "edx", "eex", "efx" };
#define NUMREGS (sizeof(regnames)/sizeof(regnames[0]))
struct Node *regs[NUMREGS];

void haparams(struct Node *n) {

	if(!n || !ops(n)) return;

	int i, reg = 0;
        for(i=0; i<nops(n); i++) {
                if(ops(n)[i]) {
			reg = make_var_ready(ops(n)[i], VREG, ANYREG);
                        printf("\t pushl \t %%%s\n", regnames[reg]);
                }
        }
}

void hcall(struct Node *n) {

	if(!n || !ops(n) || !nops(n)) return;

	haparams(ops(n)[0]);
	printf("\t call \t %-10s\n", varname(ops(n)[1]));

}

void hfunc(struct Node *n) {

	if(!n || !n->oper.operands || !n->oper.operands[2]) return;

	printf("%s:\n", varname(n->oper.operands[2]));
	puts  ("\t push \t %rbp");
	puts  ("\t mov \t %rsp, \t %rbp");
	gencode(n->oper.operands[0]);
	puts("\t leave");
	printf("\t ret\n");
}

void hstatements(struct Node *n) {
	if(!n || !ops(n)) return;

	int i;
	for(i=nops(n)-1; i>-1; i--) {
		gencode(ops(n)[i]);
	}
}


void hLT(struct Node *n) {
	int reg1 = make_var_ready(ops(n)[1], VREG, ANYREG);
	int reg2 = make_var_ready(ops(n)[0], VREG, ANYREG);
	printf("\t cmpl \t %%%s \t %%%s\n", regnames[reg1], regnames[reg2]);
	printf("\t jge \t %s\n", n->oper.flabel);
}

void hfor(struct Node *n) {
	if(!n || !ops(n)) return;

	char *tlab = genlabel(LPLABEL);
	char *flab = genlabel(TLABEL);

	gencode(ops(n)[3]);
	printf("%s:\n", tlab);
	gencode(ops(n)[2]);
	gencode(ops(n)[0]);
	gencode(ops(n)[1]);
	printf("\t jmp %s\n", tlab);
	printf("%s: \n", flab);
}

/*
 * gets the variable ready for next instruction
 * values for required_pos
 *	VMEM : in memory
 *	VREG : in register
 *	VANY : anywhere
 * returns the register if made a register allocation attempt.
 */

int make_var_ready(struct Node *n, int required_pos, int reg) {


	switch(n->type) {

	case typeCon:
	case typeScon:
		reg = get_a_reg(ANYREG);
		printf("\t movl \t %%%s, \t $%s\n", regnames[reg], n->con.strVal);
		break;
	case typeVar:
		switch(required_pos) {
		case VMEM:
			/* caller is a funny guy, don't do any thing */
			break;
		case VANY:
		case VREG:
			if(get_var_pos(n) == VMEM) {
				reg = get_a_reg(reg);
				printf("\t movl \t %%%s \t %d(%%rbp)\n", regnames[reg], n->sfof);
			} else {
				if(n->reg == reg) return reg;
				get_a_reg(reg);
				printf("\t movl \t %%%s \t %%%s\n", regnames[reg], regnames[n->reg]);
			}
			n->reg = reg;
			regs[reg] = n;
		}
	}
	return reg;
}

int get_a_reg(int regno) {
	int x=0, i;

	if(regno == ANYREG) {
		for(i=0; i<NUMREGS; i++) {
			if(!regs[i]) return i;
			if(regs[i]->hits < regs[x]->hits) {
				x = i;
			}
		}
		return x;
	}
	if(!regs[regno]) return regno;
	if(regs[regno]->dirty) {
		/* write it back */
		printf("\t movl \t %d(%%rbp), \t %%%s\n", regs[regno]->sfof, regnames[regno]);
	}
	return regno;
}

int get_var_pos(struct Node *n) {
	if(!n) {
		printf("%s query on null", __FUNCTION__);
		exit(0);
	}
	if(n->reg == ANYREG) return VMEM;
	return (regs[n->reg] == n) | 2;
}

void hif(struct Node *n) {

	if(!n || !ops(n)) return;

	char *flabel = genlabel(TLABEL);
	((struct Node*)ops(n)[2])->oper.flabel = flabel;
	gencode(ops(n)[2]);
	gencode(ops(n)[1]);
	printf("%s:\n", flabel);
	gencode(ops(n)[0]);
}

void hEQ(struct Node *n) {

	if(!n || !ops(n)) return;

	make_var_ready(ops(n)[0], VREG, 0);
	make_var_ready(ops(n)[1], VREG, 0);

	printf("\t movl \t %%%s, \t %%%s\n", regnames[opat(n, 0)->reg], regnames[opat(n, 1)->reg]);
	if(n->oper.flabel) { printf("\t jne \t %s", n->oper.flabel); }
}

void get_rodata(struct Node *n) {

	if(!n) return;

	if(n->type == typeScon) {

		char *lab = genlabel(SLABEL);

		printf("%s:\n\t .string %s\n", lab, n->con.strVal);
		strcpy(n->con.strVal, lab);
	}

	if(!ops(n)) return;

	int i;
	for(i=0; i<nops(n); i++) {
		get_rodata(ops(n)[i]);
	}

}

void gen_code(struct Node *n) {

	static int rodata=0, textdata=0;
	char *mode;
	FILE *ptr;

	mode = rodata++ ? "a" : "w";
	//ptr = freopen(__rodata__, mode, stdout);
	get_rodata(n);
	//fclose(ptr);

	mode = textdata++ ? "a" : "w";
	//ptr = freopen(__textdata__, mode, stdout);
	gencode(n);
	//fclose(ptr);

}

void gencode(struct Node *n) {

	if(!n) return;

	switch(n->type) {
	case typeCon:
		break;
	case typeOp:
		switch(n->oper.op) {

		case tCALL:
			hcall(n);
			break;
		case tFUNCTION:
			hfunc(n);
			break;
		case tSTATEMENTS:
			hstatements(n);
			break;
		case tFOR:
			hfor(n);
			break;
		case tEQ:
			hEQ(n);
			break;
		case tIF:
			hif(n);
			break;
		case tLT:
			hLT(n);
			break;
		}
		break;
	}
}


char *genlabel(int type) {

	static int slabel=0, looplabel=0, templabel=0;
	int val;
	char *str, buffer[100];

	switch(type) {

	case SLABEL:
		str = "STR";
		val = slabel++;
		break;
	case LPLABEL:
		str = "LOOP";
		val = looplabel++;
		break;
	case TLABEL:
		str = "LABEL";
		val = templabel++;
		break;
	}
	sprintf(buffer, "%s%d", str, val);
	return new_cstr(buffer);
}

