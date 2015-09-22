c:\GnuWin32\bin\flex AL.l
pause
c:\GnuWin32\bin\bison -dyv AS.y
pause
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o TP.exe
pause
pause
TP.exe Prueba.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del TPFinal.exe
pause
