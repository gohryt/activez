const std = @import("std");
const BuiltinType = std.builtin.Type;
const Allocator = std.mem.Allocator;
const Ring = @import("Ring.zig");
const Registers = @import("Registers.zig");
const syscall = @import("syscall.zig");
const Errno = syscall.Errno;

const Context = @This();

registers: Registers,
data: [8]usize,

const stack_len: usize = 2 * @import("asphyxiaz").memory.megabyte;

pub fn From(comptime Handler: type) type {
    if (!@hasDecl(Handler, "handle"))
        @compileError("Handler argument should be type with handle function declaration");

    const handler_type_info: BuiltinType = @typeInfo(Handler);

    if (handler_type_info != .@"struct")
        @compileError("Handler argument should be extern struct with first field of type Context");

    const handler_struct: BuiltinType.Struct = handler_type_info.@"struct";

    if (handler_struct.layout != .auto or handler_struct.fields.len == 0 or handler_struct.fields[0].type != Context)
        @compileError("Handler argument should be struct with first field of type Context");

    const handle_type_info: BuiltinType = @typeInfo(@TypeOf(Handler.handle));

    if (handle_type_info != .@"fn")
        @compileError("Handler.handle declaration should be fn(handler_ptr: *Handler) callconv(.Unspecified)");

    const handle_fn: BuiltinType.Fn = handle_type_info.@"fn";

    if (handle_fn.calling_convention != .auto or handle_fn.params.len != 1 or handle_fn.params[0].type != *Handler)
        @compileError("Handler.handle declaration should be fn(handler_ptr: *Handler) callconv(.Unspecified)");

    const exit_function_ptr: *const fn () callconv(.SysV) void = switch (handle_fn.return_type.?) {
        void => &context_exit,
        *Context => &context_exit_to,
        else => @compileError("Handler.handle declaration should return void or *Context"),
    };

    const arguments_fields: []const BuiltinType.StructField = handler_struct.fields[1..];

    const Arguments: type = @Type(.{
        .@"struct" = .{
            .layout = .auto,
            .fields = arguments_fields,
            .decls = &.{},
            .is_tuple = false,
        },
    });

    return struct {
        handler: Handler,

        const Self = @This();

        pub fn init(self_ptr: *Self, arguments: Arguments) !void {
            inline for (arguments_fields) |field| {
                @field(self_ptr.handler, field.name) = @field(arguments, field.name);
            }

            const result: usize = syscall.mmap(null, stack_len, .{ .read = true, .write = true }, .{ .type = .private, .anonymous = true, .grows_down = true, .stack = true }, -1, 0);
            if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));

            context_init(&self_ptr.handler.context, @ptrFromInt(result + stack_len), &Handler.handle, exit_function_ptr);
        }

        pub fn deinit(self_ptr: *Self) void {
            const stack_ptr: [*]u8 = context_deinit(&self_ptr.handler.context);
            _ = syscall.munmap(stack_ptr - stack_len, stack_len);
        }
    };
}

pub inline fn yield(context_ptr: *Context) void {
    context_yield(context_ptr);
}

pub inline fn yieldTo(context_ptr: *Context, to_ptr: *Context) void {
    context_yield_to(context_ptr, to_ptr);
}

const architecture = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @embedFile("Context_amd64.s"),
    else => {
        @compileError("CPU architecture not supported");
    },
};

comptime {
    asm (architecture);
}

extern fn context_init(context_ptr: *Context, stack_ptr: [*]u8, function_ptr: *const anyopaque, exit_function_ptr: *const anyopaque) callconv(.SysV) void;
extern fn context_deinit(context_ptr: *Context) callconv(.SysV) [*]u8;
extern fn context_exit() callconv(.SysV) void;
extern fn context_exit_to() callconv(.SysV) void;
extern fn context_yield(context_ptr: *Context) callconv(.SysV) void;
extern fn context_yield_to(context_ptr: *Context, to_ptr: *Context) callconv(.SysV) void;
