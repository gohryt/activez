const std = @import("std");
const BuiltinType = std.builtin.Type;
const Allocator = std.mem.Allocator;

const Context = @This();

registers: Registers,
mode: [8]usize,

pub const Registers = struct {
    data: [8]usize,

    inline fn init(registers_ptr: *Registers, stack_len: usize, stack_ptr: [*]u8, handle_ptr: *const anyopaque) void {
        context_registers_init(registers_ptr, stack_len, stack_ptr, handle_ptr);
    }

    inline fn deinit(registers_ptr: *Registers) Stack {
        return context_registers_deinit(registers_ptr);
    }

    pub inline fn swap(registers_ptr: *Registers, to_ptr: *Registers) void {
        context_registers_swap(registers_ptr, to_ptr);
    }
};

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

    return struct {
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

fn init(context_ptr: *Context, allocator: Allocator, function_ptr: *const anyopaque) !void {
    const stack: []u8 = try allocator.allocWithOptions(u8, 4 * 1024 * 1024, 16, null);
    context_ptr.registers.init(stack.len, stack.ptr + stack.len, function_ptr);
}

fn deinit(context_ptr: *Context, allocator: Allocator) void {
    const stack: Stack = context_ptr.registers.deinit();
    allocator.free((stack.ptr - stack.len)[0..stack.len]);
}

pub inline fn yield(context_ptr: *Context) void {
    _ = context_ptr;
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

extern fn context_registers_init(registers_ptr: *Registers, stack_len: usize, stack_ptr: [*]u8, function_ptr: *const anyopaque) void;
extern fn context_registers_deinit(registers_ptr: *Registers) Stack;
extern fn context_registers_swap(from_ptr: *Registers, to_ptr: *Registers) void;

const Stack = extern struct {
    ptr: [*]u8,
    len: usize,
};
