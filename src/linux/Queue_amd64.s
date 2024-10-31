# Queue 0 128 =
#   registers 0 (Context) 64 = Registers
#   data      64(Context) 64 =
#     head_ptr  (data) 8
#     tail_ptr 8(data) 8

.global queue_push;
.type   queue_push, @function;
queue_push: # rdi = context_ptr: *Context, rsi = queue_ptr: *Queue => rax = context_ptr: *Context
    movq  %rsi,          72(%rdi) # context_ptr.queue_ptr = queue_ptr
    movq  64(%rsi),      %rax
    testq %rax,          %rax
    jz    head_ptr_null
head_ptr:                         # if (queue_ptr.head_ptr != null)
    movq  72(%rsi),      %rax     #     queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rdi,          80(%rax)
    jmp   tail_ptr
head_ptr_null:                    # else
    movq  %rdi,          64(%rsi) #     queue_ptr.head_ptr = context_ptr
tail_ptr:
    movq  %rdi,          72(%rsi) # queue_ptr.tail_ptr = context_ptr
    xorq  %rax,          %rax
    xchgq %rax,          80(%rdi) # return = context_ptr.next_ptr; context_ptr.next_ptr = 0
    ret

.global queue_wait;
.type   queue_wait, @function;
queue_wait: # rdi = queue_ptr: *Queue
    xorq  %rsi,           %rsi
    xchgq %rsi,           64(%rdi) # return = queue_ptr.head_ptr; queue_ptr.head_ptr = 0
    jmp   registers_swap
