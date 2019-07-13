//push constant
@3030
D=A
@SP
A=M
M=D
@SP
M=M+1

//pop pointer
@THIS
D=A
@0
D=D+A
@R13
M=D
@SP
M=M-1
@SP
A=M
D=M
@R13
A=M
M=D

//push constant
@3040
D=A
@SP
A=M
M=D
@SP
M=M+1

//pop pointer
@THIS
D=A
@1
D=D+A
@R13
M=D
@SP
M=M-1
@SP
A=M
D=M
@R13
A=M
M=D

//push constant
@32
D=A
@SP
A=M
M=D
@SP
M=M+1

//pop this
@THIS
D=M
@2
D=D+A
@R13
M=D
@SP
M=M-1
@SP
A=M
D=M
@R13
A=M
M=D

//push constant
@46
D=A
@SP
A=M
M=D
@SP
M=M+1

//pop that
@THAT
D=M
@6
D=D+A
@R13
M=D
@SP
M=M-1
@SP
A=M
D=M
@R13
A=M
M=D

//push pointer
@THIS
D=A
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1

//push pointer
@THIS
D=A
@1
A=D+A
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

//push this
@THIS
D=M
@2
A=D+A
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

//push that
@THAT
D=M
@6
A=D+A
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
