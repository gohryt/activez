const std = @import("std");
const Tag = std.Target.Os.Tag;

const tag: Tag = @import("builtin").target.os.tag;

pub const Context = switch (tag) {
    .linux => @import("linux/Context.zig"),
    else => {
        @compileError("OS not supported");
    },
};

pub const Queue = switch (tag) {
    .linux => @import("linux/Queue.zig"),
    else => {
        @compileError("OS not supported");
    },
};
