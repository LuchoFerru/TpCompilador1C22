c:\LYC\GnuWin32\bin\flex Lexico.l
pause
c:\LYC\GnuWin32\bin\bison -dyv Sintactico.y
pause
c:\MinGW\bin\gcc.exe  lex.yy.c  y.tab.c  -o Segunda.exe
pause
Segunda.exe  prueba.txt
pause
