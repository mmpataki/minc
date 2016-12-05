
rm temp.y
clear
cat token.y >> temp.y
cat 054.y >> temp.y
cat 666.y >> temp.y
cat 128.y >> temp.y
cat trailer.y >> temp.y
yacc -dv temp.y
lex LEX_PART.l
gcc y.tab.c lex.yy.c -ll -o minc -g
rm y.tab.c lex.yy.c  y.tab.h #y.output
./minc "$1" < test.c
#rm minc
