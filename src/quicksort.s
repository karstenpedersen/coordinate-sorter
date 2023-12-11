# Sorts array using quicksort.
# Args:
#   rdi: array address
#   rsi: low index
#   rdx: high index
.globl quicksort
.type quicksort, @function
quicksort:
    # function prolog
    push %rbp
    movq %rsp, %rbp

    # early return if high <= low
    cmpq %rsi, %rdx
    jle .Lquicksort_done

    # save arguments to stack
    push %rdi
    push %rsi
    push %rdx

    # partition array
    call partition
    push %rax

    # get pointer to array, low index, and partition index - 1
    movq -8(%rbp), %rdi                 # get array
    movq -16(%rbp), %rsi                # get low index
    movq -32(%rbp), %rdx                # get partition index
    subq $1, %rdx
    
    # quicksort beneath partition index
    call quicksort

    # get pointer to array, high index, and partition index + 1
    movq -8(%rbp), %rdi                 # get array
    movq -24(%rbp), %rdx                # get high index
    movq -32(%rbp), %rsi                # get partition index
    addq $1, %rsi

    # quicksort above partition index
    call quicksort
.Lquicksort_done:
    # function epilog
    leave
    ret


# Partitions array using last element as pivot.
# Args:
#   rdi: array address
#   rsi: low index
#   rdx: high index
.type partition, @function
partition:
    # setup pivot and i, j counters
    leaq (%rdi, %rdx, 4), %rcx          # pointer to pivot
    movq %rsi, %r8                      # i counter
    subq $1, %r8
    movq %rsi, %r9                      # j counter
    decq %rdx                           # decrement rdx to get high - 1
.Lpartition_for:
    # check if done
    cmpq %r9, %rdx
    jl .Lpartition_done
   
    # get pointer to coordinate at j
    leaq (%rdi, %r9, 4), %r10
    movw (%r10), %r11w                  # get y-element at j
    cmpw %r11w, (%rcx)                  # check if pivot <= y-element at j
    jle .Lpartition_for_update

    # increment i
    incq %r8

    # swap coordinates at i and j
    push %rdi                           # save rdi (array address)
    leaq (%rdi, %r8, 4), %rsi           # get address to coordinate i
    movq %r10, %rdi                     # move coordinate at j
    call swap
    pop %rdi                            # restore rdi
.Lpartition_for_update:
    # increment j
    incq %r9
    jmp .Lpartition_for
.Lpartition_done:
    # increment i
    incq %r8

    # swap coordinate at i with pivot
    leaq (%rdi, %r8, 4), %rsi
    movq %rcx, %rdi
    call swap
    
    # return partition index
    movq %r8, %rax
    ret


# Swaps two 4 byte coordinates in memory.
# Args:
#   rdi: first coordinate
#   rsi: second coordinate
.type swap, @function
swap:
    push %r12
    push %r13
    movl (%rdi), %r12d
    movl (%rsi), %r13d
    movl %r13d, (%rdi)
    movl %r12d, (%rsi)
    pop %r13
    pop %r12
    ret

