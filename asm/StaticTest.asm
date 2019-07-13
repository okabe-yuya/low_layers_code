//push constant
@111
D=A
@SP
A=M
M=D
@SP
M=M+1

//push constant
@333
D=A
@SP
A=M
M=D
@SP
M=M+1

//push constant
@888
D=A
@SP
A=M
M=D
@SP
M=M+1

//push static
@SP
AM=M-1
D=M
@StaticTest.8
M=D

//push static
@SP
AM=M-1
D=M
@StaticTest.3
M=D

//push static
@SP
AM=M-1
D=M
@StaticTest.1
M=D

//push static
@StaticTest.3
D=M
@SP
A=M
M=D
@SP
M=M+1

//push static
@StaticTest.1
D=M
@SP
A=M
M=D
@SP
M=M+1

//sub
@SP
M=M-1
@SP
A=M
D=M
@SP
M=M-1
@SP
A=M
M=M-D
@SP
M=M+1

//push static
@StaticTest.8
D=M
@SP
A=M
M=D
@SP
M=M+1

//add
@SP
M=M-1
@SP
A=M
D=M
@SP
M=M-1
@SP
A=M
M=M+D
@SP
M=M+1
