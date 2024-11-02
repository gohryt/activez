# Registers 0 64 =
#   stack_ptr 0 (Registers) 8
#   rbx       8 (Registers) 8
#   rbp       16(Registers) 8
#   r12       24(Registers) 8
#   r13       32(Registers) 8
#   r14       40(Registers) 8
#   r15       48(Registers) 8
#   rsp       56(Registers) 8

.global registers_swap;
.type   registers_swap, @function;
registers_swap: # rdi = registers_ptr: *Registers, rsi = to_ptr: *Registers
    movq %rbx,           8 (%rdi)
    movq %rbp,           16(%rdi)
    movq %r12,           24(%rdi)
    movq %r13,           32(%rdi)
    movq %r14,           40(%rdi)
    movq %r15,           48(%rdi)
    movq %rsp,           56(%rdi) # registers_ptr.rsp = rsp
    movq %rsi,           %rdi
    jmp  registers_exit

.global registers_exit;
.type   registers_exit, @function;
registers_exit: # rdi = to_ptr: *Registers
    movq 8 (%rdi), %rbx
    movq 16(%rdi), %rbp
    movq 24(%rdi), %r12
    movq 32(%rdi), %r13
    movq 40(%rdi), %r14
    movq 48(%rdi), %r15
    movq 56(%rdi), %rsp # rsp = registers_ptr.rsp
    ret
