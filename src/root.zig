const std = @import("std");

pub const linux = @import("linux/root.zig");

const target_OS = switch (@import("builtin").target.os.tag) {
    .linux => linux,
    else => {
        @compileError("OS not supported");
    },
};

pub const Context = target_OS.Context;
pub const Queue = target_OS.Queue;
pub const File = target_OS.File;
pub const getStdin = target_OS.getStdin;
pub const getStdout = target_OS.getStdout;
pub const getStderr = target_OS.getStderr;
