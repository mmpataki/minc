clear
cp ../gen.h ../symtab.h ../ntypes.h ../codgen.h ../codgen.c            .
cat yacp.y > temp.y
cat ../trailer.y >> temp.y
cat antrailer.c >> temp.y
yacc -dv temp.y
lex lexp.l
gcc lex.yy.c y.tab.c -ll
rm gen.h symtab.h ntypes.h codgen.h codgen.c
./a.out < test.c 2> output
echo
cat output
echo
rm a.out temp.y output

