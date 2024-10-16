const std = @import("std");
const BuiltinType = std.builtin.Type;
const mem = std.mem;
const Allocator = mem.Allocator;

pub const Queue = extern struct {
    registers: Context.Registers,
    head_ptr: ?*Context,
    tail_ptr: ?*Context,

    pub fn wait(context_anytype: anytype) !void {
        var queue: Queue = mem.zeroInit(Queue, .{});

        switch (@typeInfo(@TypeOf(context_anytype))) {
            .pointer => |pointer| {
                const child_type_info: BuiltinType = @typeInfo(pointer.child);

                if (child_type_info != .@"struct")
                    @compileError("context should be properly created through init function");

                const child_struct: BuiltinType.Struct = child_type_info.@"struct";

                const handle_type_info: BuiltinType = @typeInfo(child_struct.fields[0].type);

                if (handle_type_info != .@"struct")
                    @compileError("context should be properly created through init function");

                const handle_struct: BuiltinType.Struct = handle_type_info.@"struct";

                if (handle_struct.fields[0].type != Context)
                    @compileError("context should be properly created through init function");

                switch (pointer.size) {
                    .One => {
                        _ = queue.push(@ptrCast(context_anytype));
                    },
                    .Slice => {
                        for (context_anytype) |*context_ptr| {
                            _ = queue.push(@ptrCast(context_ptr));
                        }
                    },
                    else => @compileError("context_anytype argument should be pointer or slice"),
                }
            },
            else => @compileError("context_anytype argument should be pointer or slice"),
        }

        while (queue.takeHead()) |context_ptr| {
            queue.registers.swap(&context_ptr.registers);
        }
    }

    inline fn push(queue_ptr: *Queue, context_ptr: *Context) ?*Context {
        return queue_push(context_ptr, queue_ptr);
    }

    inline fn takeHead(queue_ptr: *Queue) ?*Context {
        return queue_take_head(queue_ptr);
    }
};

pub const Context = extern struct {
    registers: Registers,
    mode: Mode,

    const Mode = extern union {
        queue: extern struct {
            queue_ptr: ?*Queue,
            next_ptr: ?*Context,
            reserved_1: usize,
            reserved_2: usize,
            reserved_3: usize,
            reserved_4: usize,
            reserved_5: usize,
            reserved_6: usize,
        },
    };

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

        inline fn swap(registers_ptr: *Registers, to_ptr: *Registers) void {
            context_registers_swap(registers_ptr, to_ptr);
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

    pub fn From(comptime Handler: type) type {
        if (!@hasDecl(Handler, "handle"))
            @compileError("Handler argument should be type with handle function declaration");

        const handler_type_info: BuiltinType = @typeInfo(Handler);

        if (handler_type_info != .@"struct")
            @compileError("Handler argument should be extern struct with first field of type Context");

        const handler_struct: BuiltinType.Struct = handler_type_info.@"struct";

        if (handler_struct.layout != .@"extern" or handler_struct.fields.len == 0 or handler_struct.fields[0].type != Context)
            @compileError("Handler argument should be extern struct with first field of type Context");

        const handle_type_info: BuiltinType = @typeInfo(@TypeOf(Handler.handle));

        if (handle_type_info != .@"fn" or handle_type_info.@"fn".calling_convention != .Unspecified)
            @compileError("Handler.handle declaration should be fn(handler_ptr: *Handler) callconv(.Unspecified)");

        const handle_fn: BuiltinType.Fn = handle_type_info.@"fn";

        if (handle_fn.calling_convention != .Unspecified or handle_fn.params.len != 1 or handle_fn.params[0].type != *Handler)
            @compileError("Handler.handle declaration should be fn(handler_ptr: *Handler) callconv(.Unspecified)");

        const arguments_fields: []const BuiltinType.StructField = handler_struct.fields[1..];

        const Arguments: type = @Type(.{
            .@"struct" = .{
                .layout = .auto,
                .fields = arguments_fields,
                .decls = &.{},
                .is_tuple = false,
            },
        });

        return extern struct {
            handler: Handler,

            const Self = @This();

            pub fn init(self_ptr: *Self, allocator: Allocator, arguments: Arguments) !void {
                inline for (arguments_fields) |field| {
                    @field(self_ptr.handler, field.name) = @field(arguments, field.name);
                }

                try self_ptr.handler.context.init(allocator, &Handler.handle);
            }

            pub fn deinit(self_ptr: *Self, allocator: Allocator) void {
                self_ptr.handler.context.deinit(allocator);
            }
        };
    }

    pub fn init(context_ptr: *Context, allocator: Allocator, function_ptr: *const anyopaque) !void {
        const stack: []u8 = try allocator.allocWithOptions(u8, 4 * 1024 * 1024, 16, null);
        context_ptr.* = mem.zeroInit(Context, .{});
        context_ptr.registers.init(stack.len, stack.ptr + stack.len, function_ptr);
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

    pub inline fn swap(context_ptr: *Context, to_ptr: *Context) void {
        context_ptr.registers.swap(&to_ptr.registers);
    }
};

const architecture = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @embedFile("context_amd64.s"),
    else => {
        @compileError("CPU architecture not supported");
    },
};

comptime {
    asm (architecture);
}

extern fn queue_take_head(queue_ptr: *Queue) ?*Context;
extern fn queue_push(context_ptr: *Context, queue_ptr: *Queue) ?*Context;
extern fn context_yield_shelve(context_ptr: *Context) void;
extern fn context_yield_lose(context_ptr: *Context) void;
extern fn context_registers_swap(from_ptr: *Context.Registers, to_ptr: *Context.Registers) void;
extern fn context_registers_init(registers_ptr: *Context.Registers, stack_len: usize, stack_ptr: [*]u8, function_ptr: *const anyopaque) void;
extern fn context_registers_deinit(registers_ptr: *Context.Registers) Context.Stack;
