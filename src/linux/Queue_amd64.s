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
