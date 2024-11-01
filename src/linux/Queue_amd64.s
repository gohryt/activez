# Queue 0 128 =
#   registers 0 (Context) 64 = Registers
#   data      64(Context) 64 =
#     swap_function_1_ptr 0 (data) 8
#     swap_function_2_ptr 8 (data) 8
#     exit_function_1_ptr 16(data) 8
#     exit_function_2_ptr 24(data) 8
#     head_ptr            32(data) 8
#     tail_ptr            40(data) 8

.global queue_push;
.type   queue_push, @function;
queue_push: # rdi = context_ptr: *Context, rsi = queue_ptr: *Queue
    movq  %rsi,                          64 (%rdi) # context_ptr.queue_ptr = queue_ptr
    movq  104(%rsi),                     %rax
    testq %rax,                          %rax
    jz    queue_push_head_ptr_null
queue_push_head_ptr:                               # if (queue_ptr.tail_ptr != null)
    movq  %rdi,                          72 (%rax) #   queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rax,                          80 (%rdi) #   context_ptr.prev_ptr = queue_ptr.tail_ptr
    jmp   queue_push_tail_ptr
queue_push_head_ptr_null:                          # if (queue_ptr.tail_ptr == null)
    movq  %rdi,                          96 (%rsi) #   queue_ptr.head_ptr = context_ptr
    xorq  %rax,                          %rax
    movq  %rax,                          80 (%rdi) #   context_ptr.prev_ptr = 0
queue_push_tail_ptr:
    movq  %rdi,                          104(%rsi) # queue_ptr.tail_ptr = context_ptr
    movq  $0,                            72 (%rdi) # context_ptr.next_ptr = 0
    ret

.global queue_push_1;
.type   queue_push_1, @function;
queue_swap_1: # rdi = context_ptr: *Context, rdx = queue_ptr: *Queue
    movq  104(%rdx),                  %rax      # var tail_ptr = queue_ptr.tail.ptr
    testq %rax,                       %rax
    jz    queue_swap_1_head_ptr_null
queue_swap_1_head_ptr:                          # if (tail_ptr != null)
    movq  %rdi,                       72 (%rax) #   queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rax,                       80 (%rdi) #   context_ptr.prev_ptr = queue_ptr.tail_ptr
    jmp   queue_swap_1_tail_ptr
queue_swap_1_head_ptr_null:                     # if (tail_ptr == null)
    movq  %rdi,                       96 (%rdx) #   queue_ptr.head_ptr = context_ptr
    movq  $0,                         80 (%rdi) #   context_ptr.prev_ptr = 0
queue_swap_1_tail_ptr:
    movq  %rdi,                       104(%rdx) # queue_ptr.tail_ptr = context_ptr
    xorq  %rsi,                       %rsi      # var next_ptr = 0;
    xchgq %rsi,                       72 (%rdi) # next_ptr, context_ptr.next_ptr = context_ptr.next_ptr, next_ptr
    testq %rsi,                       %rsi
    jz    queue_swap_1_next_ptr_null
queue_swap_1_next_ptr:                          # if (next_ptr != null)
    movq  $0,                         80 (%rsi) #   next_ptr.prev_ptr = 0
    jmp   registers_swap
queue_swap_1_next_ptr_null:                     # if (next_ptr == null)
    movq  %rdx,                       %rsi      #   next_ptr = queue_ptr
    jmp   registers_swap

.global queue_push_2;
.type   queue_push_2, @function;
queue_swap_2: # rdi = context_ptr: *Context, rsi = to_ptr: *Context, rdx = queue_ptr: *Queue
    movq  104(%rdx),                  %rax      # var tail_ptr = queue_ptr.tail.ptr
    testq %rax,                       %rax
    jz    queue_swap_2_head_ptr_null
queue_swap_2_head_ptr:                          # if (tail_ptr != null)
    movq  %rdi,                       72 (%rax) #   queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rax,                       80 (%rdi) #   context_ptr.prev_ptr = queue_ptr.tail_ptr
    jmp   queue_swap_2_tail_ptr
queue_swap_2_head_ptr_null:                     # if (tail_ptr == null)
    movq  %rdi,                       96 (%rdx) #   queue_ptr.head_ptr = context_ptr
    movq  $0,                         80 (%rdi) #   context_ptr.prev_ptr = 0
queue_swap_2_tail_ptr:
    movq  %rdi,                       104(%rdx) # queue_ptr.tail_ptr = context_ptr
    xorq  %rcx,                       %rcx      # var next_ptr = 0;
    xchgq %rcx,                       72 (%rdi) # next_ptr, context_ptr.next_ptr = context_ptr.next_ptr, next_ptr
    testq %rcx,                       %rcx
    jz    queue_swap_2_next_ptr_null
queue_swap_2_next_ptr:                          # if (next_ptr != null)
    testq %rcx,                       %rsi
    je    queue_swap_2_next_ptr_e
queue_swap_2_next_ptr_n:                        #   if (next_ptr != to_ptr)
    movq  %rsi,                       80 (%rcx) #     next_ptr.prev_ptr = to_ptr
    movq  %rcx,                       72 (%rsi) #     to_ptr.next_ptr = next_ptr
    movq  $0,                         80 (%rsi) #     to_ptr.prev_ptr = 0
    jmp   registers_swap
queue_swap_2_next_ptr_e:                        #   if (next_ptr == to_ptr)
    movq  $0,                         80 (%rcx) #     next_ptr.prev_ptr = 0
    jmp   registers_swap
queue_swap_2_next_ptr_null:                     # if (next_ptr == null)
    movq  %rdx,                       %rsi      #   next_ptr = queue_ptr
    jmp   registers_swap

.global queue_exit_1;
.type   queue_exit_1, @function;
queue_exit_1: # rbx = context_ptr: *Context, rdx = queue_ptr: *Queue
    movq  72(%rbx),                   %rdi     # var next_ptr = 0;
    testq %rdi,                       %rdi
    jz    queue_exit_1_next_ptr_null
queue_exit_1_next_ptr:                         # if (next_ptr != null)
    movq  $0,                         80(%rdi) #   next_ptr.prev_ptr = 0
    jmp   registers_exit
queue_exit_1_next_ptr_null:                    # if (next_ptr == null)
    movq  %rdx,                       %rdi     #   next_ptr = queue_ptr
    jmp   registers_exit

.global queue_exit_2;
.type   queue_exit_2, @function;
queue_exit_2: # rbx = context_ptr: *Context, rax = to_ptr: *Context, rdx = queue_ptr: *Queue
    movq %rax,           %rdi
    jmp  registers_exit

.global queue_wait;
.type   queue_wait, @function;
queue_wait: # rdi = queue_ptr: *Queue
    leaq  queue_swap_1,   %rax
    movq  %rax,           64(%rdi) # queue_ptr.swap_function_1_ptr = queue_swap_1
    leaq  queue_swap_2,   %rax
    movq  %rax,           72(%rdi) # queue_ptr.swap_function_2_ptr = queue_swap_2
    leaq  queue_exit_1,   %rax
    movq  %rax,           80(%rdi) # queue_ptr.exit_function_1_ptr = queue_exit_1
    leaq  queue_exit_2,   %rax
    movq  %rax,           88(%rdi) # queue_ptr.exit_function_1_ptr = queue_exit_2
    xorq  %rsi,           %rsi     # var next_ptr = 0
    xchgq %rsi,           96(%rdi) # next_ptr, queue_ptr.head_ptr = queue_ptr.head_ptr, next_ptr
    jmp   registers_swap
