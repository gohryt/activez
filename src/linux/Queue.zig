const std = @import("std");
const BuiltinType = std.builtin.Type;
const mem = std.mem;
const Context = @import("Context.zig");
const Registers = @import("Registers.zig");

const Queue = @This();

registers: Registers,
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
                    _ = queue_push_init(@ptrCast(context_anytype), &queue);
                },
                .Slice => {
                    for (context_anytype) |*context_ptr| {
                        _ = queue_push_init(@ptrCast(context_ptr), &queue);
                    }
                },
                else => @compileError("context_anytype argument should be pointer or slice"),
            }
        },
        else => @compileError("context_anytype argument should be pointer or slice"),
    }

    queue_wait(&queue);
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

extern fn queue_push_init(context_ptr: *Context, queue_ptr: *Queue) callconv(.SysV) ?*Context;
extern fn queue_push(context_ptr: *Context, queue_ptr: *Queue) callconv(.SysV) ?*Context;
extern fn queue_wait(queue_ptr: *Queue) callconv(.SysV) void;
