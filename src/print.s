# Prints formatted coordinates.
# Args:
#   rdi: input array with 16-bit numbers to be printed
#   rsi: address of array to be overwritten with printable data 
#   rdx: line count
#   rcx: output buffer size
.globl printCoords
.type printCoords, @function
printCoords:
    # point rdi to last x coordinate in array
    movq %rdx, %rax
    shlq $2, %rax                   # every set of coords is 4 bytes, so multiply by 4
    addq %rax, %rdi                 # move pointer past the end of the input array
    subq $2, %rdi                   # point to last element of array

    # point rsi to last byte in output buffer
    addq %rcx, %rsi                 # point past end of buffer
    subq $1, %rsi                   # point to last byte

    # save rdx in r11 as it will be overwritten by div
    movq %rdx, %r11
    
    # reset rax
    xorq %rax, %rax
.LprintCoords_loop:
    # if rdx <= 0 then jmp to end
    cmpq $0, %r11
    jle .LprintCoords_print

    # extract data from array
    movw (%rdi), %r9w               # get x from array
    subq $2, %rdi                   # move 2 bytes towards beginning
    movw (%rdi), %r8w               # get y from array
    subq $2, %rdi                    

    # write newline
    movb $10, (%rsi)                # 10 is newline (\n) in ascii
    subq $1, %rsi

    # write y
    movw %r8w, %ax                  # setup rax with y
    call writeNumToBuffer

    # write tab
    movb $9, (%rsi)                 # 9 is tab (\t) in ascii
    subq $1, %rsi

    # write x
    movw %r9w, %ax                  # setup rax with x
    call writeNumToBuffer
    
    # move to next set of coords
    subq $1, %r11
    jmp .LprintCoords_loop
.LprintCoords_print:
    # print contents of buffer
    movq $1, %rax                   # write syscall
    movq $1, %rdi                   # stdout
    addq $1, %rsi                   # add one to point at the beginning of output buffer
    movq %rcx, %rdx
    syscall
    ret


# Converts the number in ax to ascii and writes the result to the buffer where
# rsi is pointing. Writes least significand digits in highest addresses
# starting from rsi.
# Args:
#     rax: number to write to buffer
.type writeNumToBuffer, @function
writeNumToBuffer:
    # rax contains the input to this function for optimization
    movq $10, %r10                  # store 10 for divq operation
.LwriteNumToBuffer_loop:
    cqto                            # sign extension into rdx
    # we use divq since we only operate on non-negative numbers
    divq %r10                       # divide by 10 (since output is base 10)
    addq $48, %rdx                  # add 48 to remainder to convert to ascii
    movb %dl, (%rsi)                # move into output buffer
    subq $1, %rsi                   # move pointer for next character

    cmpq $0, %rax
    jne .LwriteNumToBuffer_loop
    ret

