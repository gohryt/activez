const std = @import("std");
const BuiltinType = std.builtin.Type;
const mem = std.mem;
const Context = @import("Context.zig");
const Registers = @import("Registers.zig");

const Queue = @This();

registers: Registers,
data: [8]usize,

pub fn wait(context_anytype: anytype) !void {
    var queue: Queue = mem.zeroInit(Queue, .{});

    switch (@typeInfo(@TypeOf(context_anytype))) {
        .@"struct" => |structure| {
            inline for (structure.fields) |field| {
                switch (@typeInfo(field.type)) {
                    .pointer => |pointer| push(&queue, pointer, @field(context_anytype, field.name)),
                    else => @compileError("context_anytype argument should be pointer or slice or tuple of pointers and slices"),
                }
            }
        },
        .pointer => |pointer| push(&queue, pointer, context_anytype),
        else => @compileError("context_anytype argument should be pointer or slice or tuple of pointers and slices"),
    }

    queue_wait(&queue);
}

fn push(queue_ptr: *Queue, comptime pointer: BuiltinType.Pointer, context_anytype: anytype) void {
    const child_type_info: BuiltinType = @typeInfo(pointer.child);

    if (child_type_info != .@"struct")
        @compileError("context should be properly created through Context.From function");

    const child_struct: BuiltinType.Struct = child_type_info.@"struct";

    const handle_type_info: BuiltinType = @typeInfo(child_struct.fields[0].type);

    if (handle_type_info != .@"struct")
        @compileError("context should be properly created through Context.From function");

    const handle_struct: BuiltinType.Struct = handle_type_info.@"struct";

    if (handle_struct.fields[0].type != Context)
        @compileError("context should be properly created through Context.From function");

    switch (pointer.size) {
        .One => {
            queue_push(@ptrCast(context_anytype), queue_ptr);
        },
        .Slice => {
            for (context_anytype) |*context_ptr| queue_push(@ptrCast(context_ptr), queue_ptr);
        },
        else => @compileError("context_anytype argument should be pointer or slice or tuple of pointers and slices"),
    }
}

const architecture = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @embedFile("Queue_amd64.s"),
    else => {
        @compileError("CPU architecture not supported");
    },
};

comptime {
    asm (architecture);
}

extern fn queue_push(context_ptr: *Context, queue_ptr: *Queue) callconv(.SysV) void;
extern fn queue_wait(queue_ptr: *Queue) callconv(.SysV) void;
