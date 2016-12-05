gcc ntgen.c -o ntgen -g
./ntgen NODETYPES nodeptypes.txt > ntypes.h
mv ntypes.h ..
