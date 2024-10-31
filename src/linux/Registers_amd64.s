# Registers 0 64 =
#   rbx   (Registers) 8 registers_ptr
#   rbp 8 (Registers) 8
#   r12 16(Registers) 8
#   r13 24(Registers) 8
#   r14 32(Registers) 8
#   r15 40(Registers) 8
#   rsp 48(Registers) 8
#   rip 56(Registers) 8

.global registers_swap;
.type   registers_swap, @function;
registers_swap: # rdi = registers_ptr: *Registers, rsi = to_ptr: *Registers
    movq %rbx,       (%rdi)
    movq %rbp,     8 (%rdi)
    movq %r12,     16(%rdi)
    movq %r13,     24(%rdi)
    movq %r14,     32(%rdi)
    movq %r15,     40(%rdi)
    leaq 8 (%rsp), %rax
    movq %rax,     48(%rdi) # real rsp
    movq   (%rsp), %rax
    movq %rax,     56(%rdi) # real rip
    movq %rsi,     %rdi

.global registers_exit;
.type   registers_exit, @function;
registers_exit: # rdi = to_ptr: *Registers
    movq   (%rdi), %rbx
    movq 8 (%rdi), %rbp
    movq 16(%rdi), %r12
    movq 24(%rdi), %r13
    movq 32(%rdi), %r14
    movq 40(%rdi), %r15
    movq 48(%rdi), %rsp # load rsp
    movq 56(%rdi), %rax # load rip
    jmp  *%rax
