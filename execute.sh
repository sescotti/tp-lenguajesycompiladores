#!/bin/bash


flex Lexico.l
bison -dyv Sintactico.y

gcc lex.yy.c y.tab.c -o TP

chmod +x TP
./TP Prueba.txt

rm -f lex.yy.c
rm -f y.tab.c
rm -f y.output
rm -f y.tab.h
rm -f TP
