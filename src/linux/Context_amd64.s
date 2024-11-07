# Context 0 128 =
#   registers 0 (Context) 64 = Registers
#   data      64(Context) 64 =
#     mode_ptr 0 (data) 8
#     if (mode_ptr is *Queue)
#       next_ptr 8 (data) 8
#       prev_ptr 16(data) 8

.global context_init;
.type   context_init, @function;
context_init: # rdi = context_ptr: *Context, rsi = stack_ptr: [*]u8, rdx = function_ptr: *const anyopaque, rcx = exit_function_ptr: *const anyopaque
    movq %rsi,           (%rdi) # context_ptr.registers.stack_ptr = stack_ptr
    movq %rdi,         8 (%rdi) # context_ptr.registers.rbx = context_ptr
    subq $16,          %rsi     # stack_ptr -= 16
    movq %rdx,           (%rsi) # stack_ptr[0] = function_ptr
    movq %rcx,         8 (%rsi) # stack_ptr[1] = exit_function_ptr
    movq %rsi,         56(%rdi) # context_ptr.registers.rsp = stack_ptr
    ret

.global context_deinit;
.type   context_deinit, @function;
context_deinit: # rdi = context_ptr: *Context -> rax = stack_ptr: [*]u8
    movq (%rdi), %rax # stack_ptr = context_ptr.registers.stack_ptr
    ret

.global context_yield;
.type   context_yield, @function;
context_yield: # rdi = context_ptr: *Context
    movq  64(%rdi), %rdx # var mode_ptr = context_ptr
    movq  64(%rdx), %rax # var swap_function_ptr = mode_ptr.swap_function_ptr
    jmp   *%rax          # swap_function_ptr()

.global context_yield_to;
.type   context_yield_to, @function;
context_yield_to: # rdi = context_ptr: *Context, rsi = to_ptr: *Context
    movq  64(%rdi), %rdx # var mode_ptr = context_ptr
    movq  72(%rdx), %rax # var swap_to_function_ptr = mode_ptr.swap_to_function_ptr
    jmp   *%rax          # swap_function_2_ptr()

.global context_yield_lose;
.type   context_yield_lose, @function;
context_yield_lose: # rdi = context_ptr: *Context
    movq  64(%rdi), %rdx # var mode_ptr = context_ptr
    movq  80(%rdx), %rax # var swap_lose_function_ptr = mode_ptr.swap_lose_function_ptr
    jmp   *%rax          # swap_lose_function_ptr()

.global context_yield_to_lose;
.type   context_yield_to_lose, @function;
context_yield_to_lose: # rdi = context_ptr: *Context, rsi = to_ptr: *Context
    movq  64(%rdi), %rdx # var mode_ptr = context_ptr
    movq  88(%rdx), %rax # var swap_to_lose_function_ptr = mode_ptr.swap_to_lose_function_ptr
    jmp   *%rax          # swap_to_lose_function_ptr()

.global context_exit;
.type   context_exit, @function;
context_exit: # rbx = context_ptr: *Context
    movq  64(%rbx), %rdx # var mode_ptr = context_ptr
    movq  96(%rdx), %rax # var exit_function_ptr = mode_ptr.exit_function_ptr
    jmp   *%rax          # exit_function_ptr()

.global context_exit_to;
.type   context_exit_to, @function;
context_exit_to: # rbx = context_ptr: *Context, rax = to_ptr: *Context
    movq  64 (%rbx), %rdx # var mode_ptr = context_ptr
    movq  104(%rdx), %rax # var exit_to_function_ptr = mode_ptr.exit_to_function_ptr
    jmp   *%rax          # exit_to_function_ptr()
