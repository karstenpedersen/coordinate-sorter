.globl _start

# Entry point for program.
# 
# The program should be called with a file name as the first command-line 
# argument.
_start:
    # check correct program usage
    # there should be 2 entries on the stack
    cmpq $2, (%rsp)
    jne usageError

    # get command-line argument
    movq 16(%rsp), %rdi

    # load coordinate data to rax
    # open file (rdi contains filename)
    movq $2, %rax               # open syscall
    movq $0, %rsi               # 0 = 0_RDONLY flag because we are reading from the file
    syscall
    movq %rax, %r12             # fd is returned by open(), save it in r12

    # check file descriptor
    cmpq $0, %rax
    jl fileNotFoundError

    # get file size
    movq %r12,  %rdi            # file descriptor
    call getFileSize
    movq %rax, %r13             # save file size in r13

    # allocate a buffer for the file contents
    movq %r13, %rdi             # buffer size = file size
    call allocate
    movq %rax, %r14             # save pointer in r14

    # write file contents into buffer
    movq $0, %rax               # read
    movq %r12, %rdi             # fd
    movq %r14, %rsi             # buffer
    movq %r13, %rdx             # size
    syscall
    
    # close file
    movq $3, %rax               # close syscall
    movq %r12, %rdi             # file descriptor
    syscall

    # get line count
    movq %r14, %rdi             # rdi gets pointer to the allocated buffer
    movq %r13, %rsi             # rsi gets file size
    call getLineCount
    movq %rax, %r12             # save line count in r12

    # allocate buffer for coordinate array 
    # we store each number in 2 bytes, so we need 4 bytes per line
    # buffer size = linecount * 4 
    movq %rax, %rdi             # copy line count
    shlq  $2, %rdi              # shifting left twice is the same as multiplying by 4
    call allocate
    movq %rax, %r15             # save list buffer in r15 

    # parse data from the file buffer to the list buffer
    movq %r14, %rdi             # the pointer to the file content buffer
    movq %r13,  %rsi            # the size of the file content buffer
    movq %rax, %rdx             # rdx gets pointer to list buffer
    call parseData

    # sort coordinates
    movq %r15, %rdi
    movq $0, %rsi
    movq %r12, %rdx
    decq %rdx
    call quicksort

    # print coordinates
    movq %r15, %rdi             # sorted array address
    movq %r14, %rsi             # output buffer
    movq %r12, %rdx             # line count
    movq %r13, %rcx             # output buffer length
    call printCoords
success:
    movq $0, %rdi           	# success error code
    jmp exit
usageError:
    movq $1, %rdi
    jmp exit
fileNotFoundError:
    movq $2, %rdi
    jmp exit
exit:
    movq $60, %rax              # exit syscall 
    syscall

