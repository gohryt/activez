# Queue 0 128 =
#   registers 0 (Context) 64 = Registers
#   data      64(Context) 64 =
#     swap_function_ptr         0 (data) 8
#     swap_to_function_ptr      8 (data) 8
#     swap_lose_function_ptr    16(data) 8
#     swap_to_lose_function_ptr 24(data) 8
#     exit_function_ptr         32(data) 8
#     exit_to_function_ptr      40(data) 8
#     head_ptr                  48(data) 8
#     tail_ptr                  56(data) 8

.global queue_push;
.type   queue_push, @function;
queue_push: # rdi = context_ptr: *Context, rsi = queue_ptr: *Queue
    movq  %rsi,                          64 (%rdi) # context_ptr.queue_ptr = queue_ptr
    movq  120(%rsi),                     %rax
    testq %rax,                          %rax
    jz    queue_push_head_ptr_null
queue_push_head_ptr:                               # if (queue_ptr.tail_ptr != null)
    movq  %rdi,                          72 (%rax) #   queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rax,                          80 (%rdi) #   context_ptr.prev_ptr = tail_ptr
    jmp   queue_push_tail_ptr
queue_push_head_ptr_null:                          # if (queue_ptr.tail_ptr == null)
    movq  %rdi,                          112(%rsi) #   queue_ptr.head_ptr = context_ptr
    movq  $0,                            80 (%rdi) #   context_ptr.prev_ptr = 0
queue_push_tail_ptr:
    movq  %rdi,                          120(%rsi) # queue_ptr.tail_ptr = context_ptr
    movq  $0,                            72 (%rdi) # context_ptr.next_ptr = 0
    ret

.global queue_swap;
.type   queue_swap, @function;
queue_swap: # rdi = context_ptr: *Context, rdx = queue_ptr: *Queue
    movq  120(%rdx),                  %rax      # var tail_ptr = queue_ptr.tail_ptr
    testq %rax,                       %rax
    jz    queue_swap_head_ptr_null
queue_swap_head_ptr:                            # if (tail_ptr != null)
    movq  %rdi,                       72 (%rax) #   queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rax,                       80 (%rdi) #   context_ptr.prev_ptr = tail_ptr
    jmp   queue_swap_tail_ptr
queue_swap_head_ptr_null:                       # if (tail_ptr == null)
    movq  %rdi,                       112(%rdx) #   queue_ptr.head_ptr = context_ptr
    movq  $0,                         80 (%rdi) #   context_ptr.prev_ptr = 0
queue_swap_tail_ptr:
    movq  %rdi,                       120(%rdx) # queue_ptr.tail_ptr = context_ptr
queue_swap_lose:
    xorq  %rsi,                       %rsi      # var next_ptr = 0;
    xchgq %rsi,                       72 (%rdi) # next_ptr, context_ptr.next_ptr = context_ptr.next_ptr, next_ptr
    testq %rsi,                       %rsi
    jz    queue_swap_next_ptr_null
queue_swap_next_ptr:                            # if (next_ptr != null)
    movq  $0,                         80 (%rsi) #   next_ptr.prev_ptr = 0
    jmp   registers_swap
queue_swap_next_ptr_null:                       # if (next_ptr == null)
    movq  %rdx,                       %rsi      #   next_ptr = queue_ptr
    jmp   registers_swap

.global queue_swap_to;
.type   queue_swap_to, @function;
queue_swap_to: # rdi = context_ptr: *Context, rsi = to_ptr: *Context, rdx = queue_ptr: *Queue
    movq  120(%rdx),                  %rax      # var tail_ptr = queue_ptr.tail_ptr
    testq %rax,                       %rax
    jz    queue_swap_to_head_ptr_null
queue_swap_to_head_ptr:                          # if (tail_ptr != null)
    movq  %rdi,                       72 (%rax) #   queue_ptr.tail_ptr.next_ptr = context_ptr
    movq  %rax,                       80 (%rdi) #   context_ptr.prev_ptr = tail_ptr
    jmp   queue_swap_to_tail_ptr
queue_swap_to_head_ptr_null:                     # if (tail_ptr == null)
    movq  %rdi,                       112(%rdx) #   queue_ptr.head_ptr = context_ptr
    movq  $0,                         80 (%rdi) #   context_ptr.prev_ptr = 0
queue_swap_to_tail_ptr:
    movq  %rdi,                       120(%rdx) # queue_ptr.tail_ptr = context_ptr
queue_swap_to_lose:
    xorq  %r8,                        %r8       # var next_ptr = 0;
    xchgq %r8,                        72 (%rdi) # next_ptr, context_ptr.next_ptr = context_ptr.next_ptr, next_ptr
    testq %r8,                        %r8
    jz    queue_swap_to_next_ptr_null
queue_swap_to_next_ptr:                          # if (next_ptr != null)
    cmpq  %r8,                        %rsi
    je    queue_swap_to_next_ptr_same
queue_swap_to_next_ptr_else:                     #   if (next_ptr != to_ptr)
    movq  %rsi,                       80 (%r8)  #     next_ptr.prev_ptr = to_ptr
    xchgq %r8,                        72 (%rsi) #     next_ptr, to_ptr.next_ptr = to_ptr.next_ptr, next_ptr
    xorq  %r9,                        %r9       #     var prev_ptr = 0
    xchgq %r9,                        80 (%rsi) #     prev_ptr, to_ptr.prev_ptr = to_ptr.prev_ptr, prev_ptr
    movq  %r8,                        72 (%r9)  #     prev_ptr.next_ptr = next_ptr
    movq  %r9,                        80 (%r8)  #     next_ptr.prev_ptr = prev_ptr
    jmp   registers_swap
queue_swap_to_next_ptr_same:                     #   if (next_ptr == to_ptr)
    movq  $0,                         80 (%r8)  #     next_ptr.prev_ptr = 0
    jmp   registers_swap
queue_swap_to_next_ptr_null:                     # if (next_ptr == null)
    movq  %rdx,                       %rsi      #   next_ptr = queue_ptr
    jmp   registers_swap

.global queue_exit;
.type   queue_exit, @function;
queue_exit: # rbx = context_ptr: *Context, rdx = queue_ptr: *Queue
    movq  72(%rbx),                   %rdi     # var next_ptr = context.ptr.next_ptr
    testq %rdi,                       %rdi
    jz    queue_exit_next_ptr_null
queue_exit_next_ptr:                         # if (next_ptr != null)
    movq  $0,                         80(%rdi) #   next_ptr.prev_ptr = 0
    jmp   registers_exit
queue_exit_next_ptr_null:                    # if (next_ptr == null)
    movq  %rdx,                       %rdi     #   next_ptr = queue_ptr
    jmp   registers_exit

.global queue_exit_to;
.type   queue_exit_to, @function;
queue_exit_to: # rbx = context_ptr: *Context, rax = to_ptr: *Context, rdx = queue_ptr: *Queue
    xorq  %rdi,                       %rdi      # var next_ptr = 0
    xchgq %rdi,                       72 (%rbx) # next_ptr, context_ptr.next_ptr = context_ptr.next_ptr, next_ptr
    testq %rdi,                       %rdi
    jz    queue_exit_to_next_ptr_null
queue_exit_to_next_ptr:                          # if (next_ptr != null)
    cmpq  %rdi,                       %rax
    je    queue_exit_to_next_ptr_same
queue_exit_to_next_ptr_else:                     #   if (next_ptr != to_ptr)
    movq  %rax,                       80 (%rdi) #     next_ptr.prev_ptr = to_ptr
    xchgq %rdi,                       72 (%rax) #     next_ptr, to_ptr.next_ptr = to_ptr.next_ptr, next_ptr
    xorq  %rcx,                       %rcx      #     var prev_ptr = 0
    xchgq %rcx,                       80 (%rax) #     prev_ptr, to_ptr.prev_ptr = to_ptr.prev_ptr, prev_ptr
    movq  %rdi,                       72 (%rcx) #     prev_ptr.next_ptr = next_ptr
    movq  %rcx,                       80 (%rdi) #     next_ptr.prev_ptr = prev_ptr
    movq  %rax,                       %rdi
    jmp   registers_exit
queue_exit_to_next_ptr_same:                     #   if (next_ptr == to_ptr)
    movq  $0,                         80 (%rdi) #     next_ptr.prev_ptr = 0
    jmp   registers_exit
queue_exit_to_next_ptr_null:                     # if (next_ptr == null)
    movq  %rdx,                       %rdi      #   next_ptr = queue_ptr
    jmp   registers_exit

.global queue_wait;
.type   queue_wait, @function;
queue_wait: # rdi = queue_ptr: *Queue
    leaq  queue_swap,   %rax
    movq  %rax,               64 (%rdi) # queue_ptr.swap_function_ptr = queue_swap_1
    leaq  queue_swap_to,      %rax
    movq  %rax,               72 (%rdi) # queue_ptr.swap_to_function_ptr = queue_swap_2
    leaq  queue_swap_lose,    %rax
    movq  %rax,               80 (%rdi) # queue_ptr.swap_function_ptr = queue_swap_1
    leaq  queue_swap_to_lose, %rax
    movq  %rax,               88 (%rdi) # queue_ptr.swap_to_function_ptr = queue_swap_2
    leaq  queue_exit,         %rax
    movq  %rax,               96 (%rdi) # queue_ptr.exit_function_ptr = queue_exit_1
    leaq  queue_exit_to,      %rax
    movq  %rax,               104(%rdi) # queue_ptr.exit_to_function_ptr = queue_exit_2
    xorq  %rsi,               %rsi      # var next_ptr = 0
    xchgq %rsi,               112(%rdi) # next_ptr, queue_ptr.head_ptr = queue_ptr.head_ptr, next_ptr
    jmp   registers_swap
