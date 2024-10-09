const std = @import("std");
const BuiltinType = std.builtin.Type;
const mem = std.mem;
const Allocator = mem.Allocator;

pub const Queue = struct {
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

                const fields: []const BuiltinType.StructField = child_type_info.@"struct".fields;

                if (fields.len < 1 or fields[0].type != Context)
                    @compileError("context should be properly created through init function");

                switch (pointer.size) {
                    .One => {
                        queue_ptr.push(@ptrCast(context_anytype));
                    },
                    .Slice => {
                        for (context_anytype) |*context_ptr| {
                            queue_ptr.push(@ptrCast(context_ptr));
                        }
                    },
                    else => @compileError("context_anytype argument should be pointer or slice"),
                }
            },
            else => @compileError("context_anytype argument should be pointer or slice"),
        }

        while (queue_ptr.pull()) |context_ptr| {
            context_ptr.swap(@as(*Context, @ptrCast(queue_ptr)));
        }
    }

    fn push(queue_ptr: *Queue, context_ptr: *Context) void {
        context_ptr.next_ptr = null;

        context_ptr.queue_ptr = queue_ptr;

        if (queue_ptr.head_ptr == null) {
            queue_ptr.head_ptr = context_ptr;
        } else {
            queue_ptr.tail_ptr.?.next_ptr = context_ptr;
        }

        queue_ptr.tail_ptr = context_ptr;
    }

    fn pushReturnNext(queue_ptr: *Queue, context_ptr: *Context) ?*Context {
        const next_ptr: ?*Context = context_ptr.next_ptr;
        queue_ptr.push(context_ptr);
        return next_ptr;
    }

    fn pull(queue_ptr: *Queue) ?*Context {
        if (queue_ptr.head_ptr) |head_ptr| {
            queue_ptr.head_ptr = null;
            return head_ptr;
        }

        return null;
    }

    extern fn swap(queue_ptr: *Queue, from_ptr: *Context) callconv(.SysV) void;
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

    return struct {
        context: Context,
        handler: Handler,

        const Self = @This();

        pub inline fn init(allocator: Allocator, handler: Handler) !Self {
            var self: Self = undefined;
            try self.initon(allocator, handler);

            return self;
        }

        pub inline fn initon(self_ptr: *Self, allocator: Allocator, handler: Handler) !void {
            try Context.initon(&self_ptr.context, allocator, &handle);
            self_ptr.handler = handler;
        }

        pub fn deinit(self_ptr: *Self, allocator: Allocator) void {
            self_ptr.context.deinit(allocator);
        }

        fn handle(context_ptr: *Context) void {
            Handler.handle(context_ptr, @ptrFromInt(@intFromPtr(context_ptr) + @sizeOf(Context)));

            if (context_ptr.next_ptr) |next_ptr| {
                next_ptr.swap(context_ptr);
            } else {
                context_ptr.queue_ptr.?.swap(context_ptr);
            }
        }
    };
}

pub const Context = struct {
    registers: Registers,
    stack: Stack,

    next_ptr: ?*Context,

    queue_ptr: ?*Queue,

    const Registers = struct {
        rbx: usize,
        rbp: usize,
        r12: usize,
        r13: usize,
        r14: usize,
        r15: usize,
        rsp: usize,
        rip: usize,
    };

    const Stack = struct {
        ptr: [*]u8,
        len: usize,
    };

    pub inline fn init(allocator: Allocator, function_ptr: *const anyopaque) !Context {
        var context: Context = undefined;
        try context.initon(allocator, function_ptr);

        return context;
    }

    pub inline fn initon(context_ptr: *Context, allocator: Allocator, function_ptr: *const anyopaque) !void {
        const stack: []u8 = try allocator.allocWithOptions(u8, 4 * 1024 * 1024, 16, null);
        const stack_ptr: [*]u8 = stack.ptr + stack.len;

        context_ptr.* = mem.zeroInit(Context, .{
            .registers = .{
                .rsp = @intFromPtr(stack_ptr - @sizeOf(usize)),
                .rip = @intFromPtr(function_ptr),
            },
            .stack = .{
                .ptr = stack_ptr,
                .len = stack.len,
            },
        });
    }

    pub fn deinit(context_ptr: *Context, allocator: Allocator) void {
        allocator.free((context_ptr.stack.ptr - context_ptr.stack.len)[0..context_ptr.stack.len]);
    }

    pub fn yield(context_ptr: *Context) void {
        if (context_ptr.queue_ptr.?.pushReturnNext(context_ptr)) |next_ptr| {
            next_ptr.swap(context_ptr);
        } else {
            context_ptr.queue_ptr.?.swap(context_ptr);
        }
    }

    extern fn swap(to_ptr: *Context, from_ptr: *Context) callconv(.SysV) void;
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
