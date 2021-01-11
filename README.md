# ParserAndMIPSCodeGenSprintf
This is a MIPS Code generator for the C function sprintf(). 
This is done as an undergraduate course project for Computer Organization and assembly language programming for Spring 2019.
--------------------------
Program Design
The programs reserves memory space for the input string, the format string,
the output buffer, and an intermediate result which is the converted characters of
its corresponding argument value, namely 1024 bytes, 1024 bytes, 1024 bytes, and
33 bytes respectively.
Four prompts for the user are also declared in the data segment. The code
segment starts by loading values in the five variables that are to be dealt with and
then printing the first message for the user, and waiting for the user input. Upon
getting the user input and printing the second message, the program calls the
parsInput function to extract the text in between the double quotations.
The parsInput function iterates over the characters of the input string and
disregards them until the first quotation is found, then it saves the characters in the
format string until it finds another quotations. The program then prints the string
and calls the function extractArgs to extract the arguments of the sprintf function
statement.
The extractArgs function iterates over the characters of the input string and
disregards them until the second quotation is found, then it checks whether the
character is either a, b, c, d, or e, if so it saves the letter in the corresponding
argument; if more than two letters are found, they are saved in the stack. The
program then outputs the third message and calls the sprintf function to save the 
Parser and MIPS Code Generator for sprintf 3
correct formatted output string in outbuf and return the number of characters in this
string. The program then prints this string, prints the fourth message, prints the
number of characters in the outbuf string, and finally exit.
The sprintf function’s first argument is outbuf in which the result will be
saved; its second argument is the format string that holds the text in between the
quotations; its third and fourth arguments are the first two arguments that were
extracted from the input string, if any. More arguments, if any, are saved in the
stack. The function iterates over the characters of the format string; if a ‘%’ is
found and the next character is either ‘d’, ‘u’, ‘b’, ‘x’, ‘X’, ‘o’, ‘c’, or ‘s’, it calls
the corresponding conversion function to convert the corresponding the argument
to printable characters, depending on the current index of ‘%’. If the next character
is not one of those eight characters, the current and next characters are saved in the
outbuf string. If the current character ‘\’ and the next character is ‘n’ or ‘t’, it saves
the ASCII value of the new line or the character ‘\t’, correspondingly, in the
current index of the outbuf string. Else, the current character is saved in the outbuf
string. A counter keeps track of every character that is saved in the outbuf string
including the converted characters of the arguments, except for new lines and tabs.
The sprintf function checks every character of the input string and calls one
of the format functions whenever required. These format functions have similar
inputs. Once the parser finds any of the conversion/ format codes it is directed to 
Parser and MIPS Code Generator for sprintf 4
the corresponding format block. The block processes the argument according to its
code by doing required conversion in case of %d, %u, %b, %x, %X, %o and then
outputting every bit in the output as a character using its ASCII code. In case the
%c the argument is masked by anding it with 255 to mask the lowest significant
byte and then loads it in the final output string. In case of %s the program loads the
contents of the string stored in the address whose value is stored in the argument
byte by byte and then copies it to the final output string until it finds the null
terminator.
Variables:
A = 5, B = 15, C = 75, D = 40, E = address of string try -> “try\n”
Program Input:
sprintf("This is an example of \tsprintf function statement.\nThe length in decimal
= %d while in binary = %b\nThe width in octal = %o while in unsigned decimal =
%u\nThe area in uppercase hexadecimal = 0x%X while in lower case hexadecimal
= 0x%x\nThe low byte of the argument d as a character is %c\nThe string pointed
to at by argument e is %s.", a, a, b, b, c, c, d, e);
Program Output:
The text between quotation is: This is an example of \tsprintf function
statement.\nThe length in decimal = %d while in binary = %b\nThe width in octal
= %o while in unsigned decimal = %u\nThe area in uppercase hexadecimal =
0x%X while in lower case hexadecimal = 0x%x\nThe low byte of the argument d
as a character is %c\nThe string pointed to at by argument e is %s.
The generated text from the sprintf function is:
This is an example of sprintf function statement.
The length in decimal = 5 while in binary = 101
The width in octal = 17 while in unsigned decimal = 15
The area in uppercase hexadecimal = 0x4B while in lower case hexadecimal =
0x4b
The low byte of the argument d as a character is (
The string pointed to at by argument e is try
The length of the output string is 325


How to run the program
The program is to be run on MARS simulator by opening the assembly file
by pressing ctrl + o, assembling it by pressing F3, and then running it by pressing
F5.
Upon running the program on MARS simulator, the program prompts the
user to enter a string containing the full sprintf function statement. An example of a
sprintf function statement would look like:
sprintf(“This is an example of sprintf function statement.\nThe length in decimal =
%d while in binary = %b\nThe width in octal = %o while in unsigned decimal =
%u\nThe area in uppercase hexadecimal = 0x%X while in lower case hexadecimal
= 0x%x\nThe height in octal = %o\nThe Volume in uppercase hexadecimal =
0x%X.”, a, a, b, b, c, c, d, e);
The program then extracts the text in between the double quotations, then
extracts the additional arguments of the sprintf function which are the variable
names that are to be converted to printable character form according to the format
specifiers in the format string. The program then fills the output string with the
correct formatted output string and outputs it; and finally the program outputs the
number of characters in its output string, not including the null at the end.



Challenges
Due to the very tight schedule in this time of the semester, we were short on
time before the first submission deadline, so it would have been challenging if the
deadline was not postponed. We had a little struggle at first debugging the program
since we did not write many comments the first time we worked on the project.
However it then became easier after commenting the code and using breakpoints to
check for errors. Also, the first time we worked, we did not understand well the
requirements and the specifications of the code like, for example, the part of
implementing a MIPS procedure to handle the sprintf function, thus, we had to
repeat a few things we did at the first time that were not exactly as required. Also
at the first time, we wrote only one function that does mostly everything required;
this was wrong with regards to debugging errors and using registers. Functional
programming is more readable, easier to debug, and better regarding using
registers as we can reuse many of the registers used in other functions.
