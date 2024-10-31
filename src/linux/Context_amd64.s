# Context 0 128 =
#   registers 0 (Context) 64 = Registers
#   data      64(Context) 64 =
#     stack_ptr   (data) 8
#     queue_ptr 8 (data) 8
#     next_ptr  16(data) 8
#     prev_ptr  24(data) 8

.global context_init;
.type   context_init, @function;
context_init: # rdi = context_ptr: *Context, rsi = stack_ptr: [*]u8, rdx = function_ptr: *const anyopaque, rcx = exit_function_ptr: *const anyopaque
    movq %rdi,           (%rdi)
    movq %rdx,         56(%rdi)
    movq %rsi,         64(%rdi)
    subq $8,           %rsi
    movq %rsi,         48(%rdi)
    movq %rcx,           (%rsi)
    ret

.global context_deinit;
.type   context_deinit, @function;
context_deinit: # rdi = context_ptr: *Context -> rax = stack_ptr: [*]u8
    movq 64(%rdi), %rax
    ret

.global context_exit;
.type   context_exit, @function;
context_exit: # rbx = context_ptr: *Context
    movq  80(%rbx),       %rdi
    testq %rdi,           %rdi
    jnz   registers_exit
    movq  72(%rbx),       %rdi
    jmp   registers_exit

.global context_exit_to;
.type   context_exit_to, @function;
context_exit_to: # rax = to_ptr: *Context, rbx = context_ptr: *Context
    movq %rax,           %rdi
    jmp  registers_exit

.global context_yield;
.type   context_yield, @function;
context_yield: # rdi = context_ptr: *Context
    movq  72(%rdi),       %rsi
    movq  64(%rsi),       %rax
    call  *%rax
    movq  %rax,           %rsi
    testq %rsi,           %rsi
    jnz   registers_swap
    movq  72(%rdi),       %rsi

.global context_yield_to;
.type   context_yield_to, @function;
context_yield_to: # rdi = context_ptr: *Context, rsi = to_ptr: *Context
    jmp registers_swap
