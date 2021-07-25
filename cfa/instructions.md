# CFA Instructions
this is a document describing all the instructions supported by the interpreter.

&nbsp;

## Call
add a new frame to the callstack, does not increment the current frames IP

machine name: `call`
| name | type | description |
| ---------- | ---- | ----------- |
| func | variable | the function to call |
| args | expression[] | the arguments to pass to the function
| result | variable | the variable to put the result in

Disassembly: `call result func args`

## Return
returns from the current stack frame  
increments the instruction counter of the stack frame below the current by one

machine name: `function_return`

| name | type | description |
| ---- | ---- | ----------- |
| exp | expression | the expression to return |

Disassembly: `function_return exp`

## Call once or more times
calls an external function at least one time  
but may call it more times than that

machine name: `call_more`

| name | type | description |
| ---- | ---- | ----------- |
| func | lua function | the function to call
| args | expression[] | the arguments to the function
| result | variable | the variable to store the return in

Disassembly: `call_more result func args`

## Call once or not at all
attempts to call an external function, may not get called

machine name: `call_less`

| name | type | description |
| ---- | ---- | ----------- |
| func | lua function | the function to call
| args | expression[] | the arguments to the function

Disassembly: `call_less func args`

## Assign
Assigns the result of an expression to a variable

machine name: `assign`

| name | type | description |
| ---- | ---- | ----------- |
| from | expression | the expression to evaluate |
| to | variable | the variable to assign to | 

Disassembly: `assign to from`

## Jump
adds a number to the instruction counter  
an offset of 0 will cause the instruction to jump to itself  
an offset of 1 will go to the next instruction   
an offset of -1 will go to the previous instruction  
and so on

machine name: `jump`
| name | type | description |
| ---- | ---- | ----------- |
| offset | expression | the amount to jump

Disassembly: `jump offset`

## Jump if
same as jump but only if a condition is true

machine name: `jump_if`

| name | type | description |
| ---- | ---- | ----------- |
| offset | expression | the amount to jump |
| exp | expression | the expression that must be true |

Disassembly: `jump_if offset exp`
## Jump if not
same as jump but only if a condition is false

machine name: `jump_if_not`

| name | type | description |
| ---- | ---- | ----------- |
| offset | expression | the amount to jump |
| exp | expression | the expression that must be false |

Disassembly: `jump_if_not offset exp`

## Exit
stops the program and prints an exit code

machine name: `exit`

| name | type | description |
| ---- | ---- | ----------- |
| exit_code | expression | the code to print |

Disassembly: `exit exit_code`