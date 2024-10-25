.global queue_take_head;
.type   queue_take_head, @function;
queue_take_head:         // rdi: *Queue => rax: *Context
    xorq  %rax, %rax
    xchgq %rax, 64(%rdi) // return = queue_ptr.head_ptr; queue_ptr.head_ptr = 0
    ret

.global queue_push;
.type   queue_push, @function;
queue_push:                       // rdi: *Context, rsi: *Queue => rax: *Context
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
    jmp   context_registers_swap
