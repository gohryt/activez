# Queue 0 128 =
#   registers 0 (Context) 64 = Registers
#   data      64(Context) 64 =
#     swap_function_1_ptr 0 (data) 8
#     swap_function_2_ptr 8 (data) 8
#     head_ptr            16(data) 8
#     tail_ptr            24(data) 8

.global queue_push;
.type   queue_push, @function;
queue_push: # rdi = context_ptr: *Context, rsi = queue_ptr: *Queue => rax = context_ptr: *Context
    movq  %rsi,                          64(%rdi) # context_ptr.queue_ptr = queue_ptr
    movq  88(%rsi),                      %rax
    testq %rax,                          %rax
    jz    queue_push_head_ptr_null
queue_push_head_ptr:                         # if (queue_ptr.tail_ptr != null)
    movq  %rdi,                          80(%rax) #   queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rax,                          80(%rdi) #   context_ptr.prev_ptr = queue_ptr.tail_ptr
    jmp   queue_push_tail_ptr
queue_push_head_ptr_null:                    # if (queue_ptr.tail_ptr == null)
    movq  %rdi,                          80(%rsi) #   queue_ptr.head_ptr = context_ptr
    xorq  %rax,                          %rax
    movq  %rax,                          80(%rdi) #   context_ptr.prev_ptr = 0
queue_push_tail_ptr:
    movq  %rdi,                          88(%rsi) # queue_ptr.tail_ptr = context_ptr
    xorq  %rax,                          %rax
    movq  %rax,                          72(%rdi) # context_ptr.next_ptr = 0
    ret

.global queue_push_1;
.type   queue_push_1, @function;
queue_swap_1: # rdi = context_ptr: *Context, rdx = queue_ptr: *Queue => rax = context_ptr: *Context
    movq  88(%rdx),       %rax
    testq %rax,           %rax
    jz    queue_swap_1_head_ptr_null
queue_swap_1_head_ptr:             # if (queue_ptr.tail_ptr != null)
    movq  %rdi,           80(%rax) #   queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rax,           80(%rdi) #   context_ptr.prev_ptr = queue_ptr.tail_ptr
    jmp   queue_swap_1_tail_ptr
queue_swap_1_head_ptr_null:        # if (queue_ptr.tail_ptr == null)
    movq  %rdi,           80(%rdx) #   queue_ptr.head_ptr = context_ptr
    xorq  %rax,           %rax
    movq  %rax,           80(%rdi) #   context_ptr.prev_ptr = 0
queue_swap_1_tail_ptr:
    movq  %rdi,           88(%rdx) # queue_ptr.tail_ptr = context_ptr
    xorq  %rsi,           %rsi
    xchgq %rsi,           72(%rdi) # return = context_ptr.next_ptr; context_ptr.next_ptr = 0
    testq %rsi,           %rsi
    jnz   registers_swap
    movq  %rdx,           %rsi
    jmp   registers_swap

.global queue_push_2;
.type   queue_push_2, @function;
queue_swap_2: # rdi = context_ptr: *Context, rsi = context_ptr: *Context, rdx = queue_ptr: *Queue => rax = context_ptr: *Context
    jmp registers_swap

.global queue_wait;
.type   queue_wait, @function;
queue_wait: # rdi = queue_ptr: *Queue
    leaq  queue_swap_1,   %rax
    movq  %rax,           64(%rdi)
    leaq  queue_swap_2,   %rax
    movq  %rax,           72(%rdi)
    xorq  %rsi,           %rsi
    xchgq %rsi,           80(%rdi) # return = queue_ptr.head_ptr; queue_ptr.head_ptr = 0
    jmp   registers_swap
