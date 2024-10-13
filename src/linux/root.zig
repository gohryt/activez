const std = @import("std");
const BuiltinType = std.builtin.Type;
const mem = std.mem;
const Allocator = mem.Allocator;

pub const Queue = extern struct {
    registers: Context.Registers = mem.zeroInit(Context.Registers, .{}),
    head_ptr: ?*Context = null,
    tail_ptr: ?*Context = null,

    pub inline fn wait(context_anytype: anytype) !void {
        var queue: Queue = .{};
        try queue.waiton(context_anytype);
    }

    pub inline fn waiton(queue_ptr: *Queue, context_anytype: anytype) !void {
        const context_type_info: BuiltinType = @typeInfo(@TypeOf(context_anytype));

        switch (context_type_info) {
            .pointer => |pointer| {
                const child_type_info: BuiltinType = @typeInfo(pointer.child);

                if (child_type_info != .@"struct")
                    @compileError("context should be properly created through init function");

                if (pointer.child != Context) {
                    const fields: []const BuiltinType.StructField = child_type_info.@"struct".fields;

                    if (fields.len < 1 or fields[0].type != Context)
                        @compileError("context should be properly created through init function");
                }

                switch (pointer.size) {
                    .One => {
                        _ = @as(*Context, @ptrCast(context_anytype)).push(queue_ptr);
                    },
                    .Slice => {
                        for (context_anytype) |*context_ptr| {
                            _ = @as(*Context, @ptrCast(context_ptr)).push(queue_ptr);
                        }
                    },
                    else => @compileError("context_anytype argument should be pointer or slice"),
                }
            },
            else => @compileError("context_anytype argument should be pointer or slice"),
        }

        while (queue_ptr.takeHead()) |context_ptr| {
            queue_ptr.registers.swap(&context_ptr.registers);
        }
    }

    inline fn takeHead(queue_ptr: *Queue) ?*Context {
        return queue_take_head(queue_ptr);
    }
};

pub fn ContextWith(comptime Handler: type) type {
    if (!@hasDecl(Handler, "handle"))
        @compileError("Handler argument should be type with handle function declaration");

    const handle_type_info: BuiltinType = @typeInfo(@TypeOf(Handler.handle));

    if (handle_type_info != .@"fn" or handle_type_info.@"fn".calling_convention != .Unspecified)
        @compileError("Handler.handle function should be of standard zig calling convention");

    const params: []const BuiltinType.Fn.Param = handle_type_info.@"fn".params;

    if (params.len < 1 or params[0].type != *Context)
        @compileError("Handler.handle function first argument should be *Context");

    if (params.len < 2 or params[1].type != *Handler)
        @compileError("Handler.handle function second argument should be *Handler");

    return extern struct {
        context: Context,
        handler: Handler,

        const Self = @This();

        pub inline fn init(self_ptr: *Self, allocator: Allocator, handler: Handler) !void {
            try self_ptr.context.init(allocator, &Handler.handle);
            self_ptr.handler = handler;
        }

        pub fn deinit(self_ptr: *Self, allocator: Allocator) void {
            self_ptr.context.deinit(allocator);
        }
    };
}

pub const Context = extern struct {
    registers: Registers,
    queue_ptr: ?*Queue,
    next_ptr: ?*Context,
    reserved_1: usize,
    reserved_2: usize,
    reserved_3: usize,
    reserved_4: usize,
    reserved_5: usize,
    reserved_6: usize,

    const Registers = extern struct {
        rbx: usize,
        rbp: usize,
        r12: usize,
        r13: usize,
        r14: usize,
        r15: usize,
        rsp: usize,
        rip: usize,

        inline fn init(registers_ptr: *Registers, stack_len: usize, stack_ptr: [*]u8, function_ptr: *const anyopaque) void {
            context_registers_init(registers_ptr, stack_len, stack_ptr, function_ptr);
        }

        inline fn deinit(registers_ptr: *Registers) Stack {
            return context_registers_deinit(registers_ptr);
        }

        inline fn swap(from_ptr: *Registers, to_ptr: *Registers) void {
            context_registers_swap(from_ptr, to_ptr);
        }
    };

    const Stack = extern struct {
        ptr: [*]u8,
        len: usize,
    };

    const YieldMode = enum {
        shelve,
        lose,
    };

    pub inline fn init(context_ptr: *Context, allocator: Allocator, function_ptr: *const anyopaque) !void {
        const stack: []u8 = try allocator.allocWithOptions(u8, 4 * 1024 * 1024, 16, null);
        const stack_ptr: [*]u8 = stack.ptr + stack.len;

        context_ptr.* = mem.zeroInit(Context, .{});

        context_ptr.registers.init(stack.len, stack_ptr, function_ptr);
    }

    pub fn deinit(context_ptr: *Context, allocator: Allocator) void {
        const stack: Stack = context_ptr.registers.deinit();
        allocator.free((stack.ptr - stack.len)[0..stack.len]);
    }

    pub inline fn yield(context_ptr: *Context, comptime yield_mode: YieldMode) void {
        switch (yield_mode) {
            .shelve => context_yield_shelve(context_ptr),
            .lose => context_yield_lose(context_ptr),
        }
    }

    pub inline fn push(context_ptr: *Context, queue_ptr: *Queue) ?*Context {
        return context_push(context_ptr, queue_ptr);
    }
};

const architecture = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @embedFile("root_amd64.s"),
    else => {
        @compileError("CPU architecture not supported");
    },
};

comptime {
    asm (architecture);
}

extern fn queue_take_head(queue_ptr: *Queue) ?*Context;
extern fn context_push(context_ptr: *Context, queue_ptr: *Queue) ?*Context;
extern fn context_yield_shelve(context_ptr: *Context) void;
extern fn context_yield_lose(context_ptr: *Context) void;
extern fn context_registers_swap(from_ptr: *Context.Registers, to_ptr: *Context.Registers) void;
extern fn context_registers_init(registers_ptr: *Context.Registers, stack_len: usize, stack_ptr: [*]u8, function_ptr: *const anyopaque) void;
extern fn context_registers_deinit(registers_ptr: *Context.Registers) Context.Stack;
