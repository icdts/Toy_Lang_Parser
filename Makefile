pa1cs441f11.exe : lex.yy.c
	g++ lex.yy.c -o pa1cs441f11.exe

lex.yy.c : pa1cs441f11.l
	lex pa1cs441f11.l
