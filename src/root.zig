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
pub const Reactor = target_OS.Reactor;
pub const File = target_OS.File;
pub const Listener = target_OS.Listener;

pub const getStdinPtr = target_OS.getStdinPtr;
pub const getStdoutPtr = target_OS.getStdoutPtr;
pub const getStderrPtr = target_OS.getStderrPtr;

test "Context satisfyInterface" {}
