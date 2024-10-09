swap:
    mov %rbx,       (%rsi)
    mov %rbp,     8 (%rsi)
    mov %r12,     16(%rsi)
    mov %r13,     24(%rsi)
    mov %r14,     32(%rsi)
    mov %r15,     40(%rsi)
    lea 8 (%rsp), %rdx
    mov %rdx,     48(%rsi) // save stack pointer
    mov   (%rsp), %rdx
    mov %rdx,     56(%rsi) // save return address

    mov   (%rdi), %rbx
    mov 8 (%rdi), %rbp
    mov 16(%rdi), %r12
    mov 24(%rdi), %r13
    mov 32(%rdi), %r14
    mov 40(%rdi), %r15
    mov 48(%rdi), %rsp     // load stack pointer
    mov 56(%rdi), %rdx     // load return address

    jmp *%rdx
