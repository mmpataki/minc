/*
 * tool to genrate the array and defines of the indexes for the 
 * node names used in node creation.
 */

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>

#define __temp_file__ "mytemporaryfile1003746784.xtomas~"

int main(int argc, char *argv[]) {


        if(argc < 3) {
                printf("usage : %s <arrayname> <token_names_file>\n\n", argv[0]);
                return 0;
        }

        FILE *ptr = fopen(argv[2], "r");
        FILE *tmp = fopen(__temp_file__, "w");
        int i, bc=0, counter=0;
        char ch, obuf[100], dbuf[100];

        printf( "/*\n"
                " * This is auto generated code \n"
                " * Don't modify the code. In case modified run the \n"
                " * tool ntgen from the tools directory:\n"
                " */\n\n"
        );

        printf("char *%s[] = {\n", argv[1]);

        while( (ch = getc(ptr)) != EOF ) {
                if(ch != '\n') {
                        if(!bc && counter) putchar(',');
                        obuf[bc] = ch;
                        dbuf[bc] = toupper(ch);
                        bc++;
                }
                else {
                        if(bc == 0) continue;

                        obuf[bc] = dbuf[bc] = 0;

                        for(i=0; obuf[i]; i++) {
                                if(obuf[i] == ' ') {
                                        dbuf[i] = 0;
                                        i++;
                                        break;
                                }
                        }

                        if(obuf[i]) {
                                strcpy(obuf, &obuf[i]);
                        }

                        printf("\n\t\"%s\"", obuf);
                        fprintf(tmp, "#define  t%-20s  %4d\n", dbuf, counter++);
                        bc = 0;
                }
        }
        printf("\n};\n\n");

        fclose(ptr);
        fclose(tmp);

        tmp = fopen(__temp_file__, "r");
        while( (ch = getc(tmp)) != EOF ) {
                putchar(ch);
        }

        fclose(tmp);
        remove(__temp_file__);
}

