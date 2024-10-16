.global context_exit;
.type   context_exit, @function;
context_exit:                          // rbx: *Context
    movq  %rbx,                   %rdi
    movq  %rbp,                   8 (%rdi)
    movq  %rsp,                   48(%rdi)
    movq  72(%rdi),               %rsi
    testq %rsi,                   %rsi
    jnz   context_registers_exit
    movq  64(%rdi),               %rsi
    jmp   context_registers_exit

.global context_yield_shelve;
.type   context_yield_shelve, @function;
context_yield_shelve:                         // rdi: *Context
    movq  64(%rdi),               %rsi
    call  queue_push
    testq %rax,                   %rax
    jz    context_registers_swap
next_ptr:
    movq  %rax,                   %rsi
    jmp   context_registers_swap

.global context_yield_lose;
.type   context_yield_lose, @function;
context_yield_lose:                         // rdi: *Context
    movq  72(%rdi),               %rsi
    testq %rsi,                   %rsi
    jnz   context_registers_swap
    movq  64(%rdi),               %rsi

.global context_registers_swap;
.type   context_registers_swap, @function;
context_registers_swap:     // rdi: *Context.Registers, rsi: *Context.Registers
    movq %rbx,       (%rdi)
    movq %rbp,     8 (%rdi)
    movq %r12,     16(%rdi)
    movq %r13,     24(%rdi)
    movq %r14,     32(%rdi)
    movq %r15,     40(%rdi)
    leaq 8 (%rsp), %rdx
    movq %rdx,     48(%rdi) // save stack pointer
    movq   (%rsp), %rdx
    movq %rdx,     56(%rdi) // save return address

.global context_registers_exit;
.type   context_registers_exit, @function;
context_registers_exit: // rdi: *Context.Registers, rsi: *Context.Registers
    movq   (%rsi), %rbx
    movq 8 (%rsi), %rbp
    movq 16(%rsi), %r12
    movq 24(%rsi), %r13
    movq 32(%rsi), %r14
    movq 40(%rsi), %r15
    movq 48(%rsi), %rsp // load stack pointer
    movq 56(%rsi), %rdx // load return address

    movq %rsi,     %rdi

    jmp  *%rdx

.global context_registers_init;
.type   context_registers_init, @function;
context_registers_init:         // rdi: *Context.Registers, rsi: usize, %rdx: [*]u8, %rcx *const anyopaquew
    movq %rdi,           (%rdi)
    movq %rsi,         8 (%rdi)
    subq $8,           %rdx
    leaq context_exit, %rax
    movq %rax,           (%rdx)
    movq %rdx,         48(%rdi)
    movq %rcx,         56(%rdi)
    ret

.global context_registers_deinit;
.type   context_registers_deinit, @function;
context_registers_deinit: // rdi: *Context.Registers -> rax: [*]u8, rdx: usize
    movq 48(%rdi), %rax
    movq 8 (%rdi), %rdx
    ret
