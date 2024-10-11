.global queue_take_head;
.type   queue_take_head, @function;
queue_take_head:         // rdi: *Queue => rax: *Context
    xorq  %rax, %rax
    xchgq %rax, 64(%rdi) // return = queue_ptr.head_ptr; queue_ptr.head_ptr = 0
    ret

.global context_push;
.type   context_push, @function;
context_push:                     // rdi: *Context, rsi: *Queue => rax: *Context
    movq  %rsi,          64(%rdi) // context_ptr.queue_ptr = queue_ptr
    movq  64(%rsi),      %rax
    testq %rax,          %rax
    jz    head_ptr_null
head_ptr:                         // if (queue_ptr.head_ptr != null)
    movq  72(%rsi),      %rax     //     queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rdi,          72(%rax)
    jmp   tail_ptr
head_ptr_null:                    // else
    movq  %rdi,          64(%rsi) //     queue_ptr.head_ptr = context_ptr
tail_ptr:
    movq  %rdi,          72(%rsi) // queue_ptr.tail_ptr = context_ptr
    xorq  %rax,          %rax
    xchgq %rax,          72(%rdi) // return = context_ptr.next_ptr; context_ptr.next_ptr = 0
    ret

.global context_exit;
.type   context_exit, @function;
context_exit:                          // rbx: *Context
    movq  %rbx,                   %rdi
    movq  72(%rdi),               %rsi
    testq %rsi,                   %rsi
    jnz   context_registers_exit
    movq  64(%rdi),               %rsi
    jmp   context_registers_exit

.global context_yield;
.type   context_yield, @function;
context_yield:                         // rdi: *Context
    movq  64(%rdi),               %rsi
    call  context_push
    testq %rax,                   %rax
    jz    context_registers_swap
next_ptr:
    movq  %rax,                   %rsi

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
    addq $128,     %rsi

    jmp  *%rdx

.global context_registers_initon;
.type   context_registers_initon, @function;
context_registers_init:         // rdi: *Context.Registers, rsi: [*]u8, %rdx: *const anyopaquew
    movq %rdi,           (%rdi)
    subq $8,           %rsi
    leaq context_exit, %rax
    movq %rax,           (%rsi)
    movq %rsi,         48(%rdi)
    movq %rdx,         56(%rdi)
    ret
