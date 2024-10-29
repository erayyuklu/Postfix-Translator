.section .bss
input_buffer: .space 256
wired_zeros: .space 2
output_buffer: .space 256
number_buffer: .space 4

.section .data

string_add: .asciz "0000000 00010 00001 000 00001 0110011\n"
string_sub: .asciz "0100000 00010 00001 000 00001 0110011\n"
string_mul: .asciz "0000001 00010 00001 000 00001 0110011\n"
string_and: .asciz "0000111 00010 00001 000 00001 0110011\n"
string_or : .asciz "0000110 00010 00001 000 00001 0110011\n"
string_xor: .asciz "0000100 00010 00001 000 00001 0110011\n"
str_imm_first : .asciz " 00000 000 00010 0010011\n"
str_imm_second: .asciz " 00000 000 00001 0010011\n"

.section .text
.global _start

_start:
    mov $0, %eax                        # syscall number for sys_read
    mov $0, %edi                        # file descriptor 0 (stdin)
    lea input_buffer(%rip), %rsi        # pointer to the input buffer
    mov $256, %edx                      # maximum number of bytes to read
    syscall                             # perform the syscall

    lea input_buffer(%rip), %r15        # Let r15 be the pointer for the input buffer (To be incremented when necessary)
    lea output_buffer(%rip), %r14       # Let r14 be the pointer for the output buffer (To be incremented when necessary)

    lea number_buffer, %r13             # Store the value as a byte-sized char list given in the input string. -> First 13 and then 654 in "13 654 +"
    mov $0, %rcx                        # Index for the number buffer

main_loop:                              # Check for the character in the main loop, redirect relevant labels
    cmpb $0, (%r15)
    je exit_program

    cmpb $'\n' , (%r15)
    je newline

    cmpb $' ' , (%r15)
    je space

    cmpb $'+' , (%r15)
    je operator_add

    cmpb $'-' , (%r15)
    je operator_sub

    cmpb $'*' , (%r15)
    je operator_mul

    cmpb $'&' , (%r15)
    je operator_and

    cmpb $'|' , (%r15)
    je operator_or

    cmpb $'^' , (%r15)
    je operator_xor

    jmp number

newline:
    jmp print_func

space:
    mov $0, %rax                        # Store value of the number
    mov $0, %rcx                        # Store the counter to generate decimal

    call decimal_loop                   # Loop for decimal generation
    push %rax                           # Push the decimal value to the stack

    mov $0, %rcx                        # Set counter to 0
    inc %r15
    mov $0, (%r13)
    jmp main_loop                   

decimal_loop:
    cmpb $0, (%r13, %rcx, 1)            # If end of the number, end the loop
    je decimal_done                     # Conditional jump + Return -> Effectively Conditional Return

    movb (%r13, %rcx, 1), %bl           # Create the decimal value by multiplying the existing value by 10
    sub $48, %rbx                       # For example, there was 4 in the buffer and here comes 3.
    imul $10, %rax                      # Thew new number is 4*10 + 3 = 43 
    add %rbx, %rax                      

    inc %rcx                            # Next iteration
    jmp decimal_loop

decimal_done:
    ret


/* All the operators use the same routine. 
 * Except the actual operand
 */

operator_add:
    pop %r10                            # Take the first number, convert it to decimal and print
    mov %r10, %r9                       # Store the number in r9, it will be consumed by decimal_to_binary
    lea output_buffer(%rip), %r14       # Reset r14 to keep the start address of the output_buffer
    call decimal_to_binary              # Convert decimal number stored in r9 (i.e. first immediate) to binary
    call reg_imm_1                      # Print the immediate part of the first register
    pop %r12                            # Take the second number, convert it to decimal and print
    mov %r12, %r9                       # Store the number in r9, it will be consumed by decimal_to_binary
    lea output_buffer(%rip), %r14       # Reset r14 to keep the start address of the output_buffer
    call decimal_to_binary              # Convert decimal number stored in r9 (i.e. second immediate) to binary
    call reg_imm_2                      # Print the immediate part of the second register
    
    add %r10, %r12                      # Add the numbers popped from the stack
    push %r12                           # Push the result into the stack

    lea string_add(%rip), %rsi          # Set the instruction string for the next output for addition
    jmp end_of_operator                 # Move to the end of the operator

operator_sub:
    pop %r10
    mov %r10, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_1
    pop %r12
    mov %r12, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_2
    
    sub %r10, %r12
    push %r12

    lea string_sub(%rip), %rsi
    jmp end_of_operator

operator_mul:
    pop %r10
    mov %r10, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_1
    pop %r12
    mov %r12, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_2
    
    imul %r10, %r12
    push %r12

    lea string_mul(%rip), %rsi
    jmp end_of_operator

operator_and:
    pop %r10
    mov %r10, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_1
    pop %r12
    mov %r12, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_2
    
    and %r10, %r12
    push %r12

    lea string_and(%rip), %rsi
    jmp end_of_operator

operator_or:
    pop %r10
    mov %r10, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_1
    pop %r12
    mov %r12, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_2
    
    or %r10, %r12
    push %r12

    lea string_or(%rip), %rsi
    jmp end_of_operator

operator_xor:
    pop %r10
    mov %r10, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_1
    pop %r12
    mov %r12, %r9
    lea output_buffer(%rip), %r14
    call decimal_to_binary
    call reg_imm_2
    
    xor %r10, %r12
    push %r12

    lea string_xor(%rip), %rsi
    jmp end_of_operator

end_of_operator:

    movl $38, %edx                      # Set print size 38
    call print_func                     # Print the output string
    mov $0, %rcx                        # Reset counter
    lea number_buffer, %r13             # Reset number buffer
    inc %r15                            # Increase the pointer to the next character by 2
    inc %r15                            # ^^
    jmp main_loop                       # Go back to the main loop

reg_imm_1:
    lea output_buffer(%rip), %rsi       # Set the output buffer for the output
    mov $12, %edx                       # Set print size 12 for the immediate part
    call print_func                     # Print the immediate in binary
    lea str_imm_first(%rip), %rsi       # Set the instruction string for the output
    mov $25, %edx                       # Set print size 25 for the remaining part
    call print_func                     # Print the remaning part of the instruction
    mov $0, output_buffer               # Clear output buffer
    mov $0, %rcx                        # Reset counter
    mov $0, %r9                         # Reset value
    ret                                 # Return the caller

reg_imm_2:
    lea output_buffer(%rip), %rsi       # Set the output buffer for the output
    mov $12, %edx                       # Set print size 12 for the immediate part
    call print_func                     # Print the immediate in binary
    lea str_imm_second(%rip), %rsi      # Set the instruction string for the output
    mov $25, %edx                       # Set print size 25 for the remaining part
    call print_func                     # Print the remaning part of the instruction
    mov $0, output_buffer               # Clear output buffer
    mov $0, %rcx                        # Reset counter
    ret                                 # Return the caller

/* Initialise the process of converting a decimal number to its binary representation.
 * The actual procedure is implemented in loop_start.
 * Use loop_end to return to the caller.
 */
decimal_to_binary:
    mov $12, %rcx                       # Set the counter to 12    
    add $11, %r14                       # Move the pointer to the last character
    jmp loop_start                      # Start the loop

loop_start:
    cmp $0, %rcx                        # Check if the counter is zero
    je loop_end                         # If it is zero, exit the loop
    mov %r9, %rax                       # Move r9 to rax
    and $1, %rax                        # Perform bitwise AND with 1 to get the right-most bit of the value
    add $48, %al                        # Convert decimal value to ASCII
    movb %al, (%r14)                    # Move the result to output buffer
    shr $1, %r9                         # Shift the value to the right by 1 to get rid of the right-most bit
    dec %r14                            # Decrement the pointer to the output buffer
    dec %rcx                            # Decrement the counter
    jmp loop_start                      # Repeat the process
    
loop_end:
    ret                                 # Return to the caller

number:
    push %rdx                           # Keep the rdx register
    movb (%r15), %dl                    # Use dl as the temporary byte storage
    movb %dl, (%r13, %rcx, 1)           # Store the byte in the number buffer using rcx as the index from the start
    pop %rdx                            # Retrieve the rdx

    inc %rcx                            # Increment the counter
    inc %r15                            # Increment the input buffer pointer
    jmp main_loop                       # Next character

/* Generic print function.
 * Assumes edx has size and rsi has address (popped from stack)
 */
print_func:
    mov $1, %eax                        # syscall number for sys_write
    mov $1, %edi                        # file descriptor 1 (stdout)
    syscall
    ret

exit_program:
    # Exit the program
    mov $60, %eax                       # syscall number for sys_exit
    xor %edi, %edi                      # exit code 0
    syscall
