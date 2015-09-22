#!/bin/bash


flex AL.l
bison -dyv AS.y

gcc lex.yy.c y.tab.c -o TP

chmod +x TP
./TP Prueba.txt

rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm TP
pause
