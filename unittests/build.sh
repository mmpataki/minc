clear
cp ../gen.h ../symtab.h ../ntypes.h ../codgen.h ../codgen.c            .
cat yacp.y > temp.y
cat ../trailer.y >> temp.y
yacc -dv temp.y
lex lexp.l
gcc lex.yy.c y.tab.c -ll
rm gen.h symtab.h ntypes.h codgen.h codgen.c
./a.out < test.c
rm a.out temp.y

