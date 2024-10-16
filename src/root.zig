const context = switch (@import("builtin").target.os.tag) {
    .linux => @import("linux/context.zig"),
    else => {
        @compileError("OS not supported");
    },
};

pub const Context = context.Context;
pub const Queue = context.Queue;
