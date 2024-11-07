const std = @import("std");
const Context = @import("Context.zig");
const syscall = @import("syscall.zig");
const Errno = syscall.Errno;
const Ring = @import("Ring.zig");

directory_FD: i32 = 0,
FD: i32 = 0,

const File = @This();

pub const init: File = .{};

pub const Stat: type = struct {
    statx: syscall.Statx = .{},

    const Error = error{
        NoSize,
    };

    pub inline fn size(stat_ptr: *Stat) !u64 {
        if (stat_ptr.statx.mask.size) return stat_ptr.statx.size else return Error.NoSize;
    }

    pub const init: Stat = .{};
};

pub fn open(file_ptr: *File, path: [*:0]u8, flags: syscall.Openat.Flags, mode: syscall.Openat.Mode) !void {
    file_ptr.directory_FD = syscall.At.CWD_FD;

    const result: usize = syscall.openat(file_ptr.directory_FD, path, flags, mode);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));

    file_ptr.FD = @intCast(result);
}

pub fn openAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Ring, path: [*:0]u8, flags: syscall.Openat.Flags, mode: syscall.Openat.Mode) !void {
    file_ptr.directory_FD = syscall.At.CWD_FD;

    var result: Ring.Result = .{
        .context_ptr = context_ptr,
    };

    try reactor_ptr.queue(.{
        .openat = .{
            .directory_FD = file_ptr.directory_FD,
            .path = path,
            .flags = flags,
            .mode = mode,
        },
    }, 0, @intFromPtr(&result));

    context_ptr.yield();

    if (result.value < 0) return Errno.toError(@enumFromInt(-result.value));

    file_ptr.FD = result.value;
}

pub fn close(file_ptr: *File) !void {
    const result: usize = syscall.close(file_ptr.FD);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));
}

pub fn closeAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Ring) !void {
    var result: Ring.Result = .{
        .context_ptr = context_ptr,
    };

    try reactor_ptr.queue(.{
        .close = .{
            .FD = file_ptr.FD,
        },
    }, 0, @intFromPtr(&result));

    context_ptr.yield();

    if (result.value < 0) return Errno.toError(@enumFromInt(-result.value));
}

pub fn stat(file_ptr: *File, stat_ptr: *Stat, path: [*:0]u8, flags: syscall.At, mask: syscall.Statx.Mask) !void {
    const result: usize = if (flags.empty_path)
        syscall.statx(file_ptr.FD, path, flags, mask, &stat_ptr.statx)
    else
        syscall.statx(file_ptr.directory_FD, path, flags, mask, &stat_ptr.statx);

    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));
}

pub fn statAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Ring, stat_ptr: *Stat, path: [*:0]u8, flags: syscall.At, mask: syscall.Statx.Mask) !void {
    var result: Ring.Result = .{
        .context_ptr = context_ptr,
    };

    if (flags.empty_path) {
        try reactor_ptr.queue(.{
            .statx = .{
                .directory_FD = file_ptr.FD,
                .path = path,
                .flags = flags,
                .mask = mask,
                .statx_ptr = &stat_ptr.statx,
            },
        }, 0, @intFromPtr(&result));
    } else {
        try reactor_ptr.queue(.{
            .statx = .{
                .directory_FD = file_ptr.directory_FD,
                .path = path,
                .flags = flags,
                .mask = mask,
                .statx_ptr = &stat_ptr.statx,
            },
        }, 0, @intFromPtr(&result));
    }

    context_ptr.yield();

    if (result.value < 0) return Errno.toError(@enumFromInt(-result.value));
}

pub fn read(file_ptr: *File, buffer: []u8) !usize {
    const result: usize = syscall.read(file_ptr.FD, buffer);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result)) else return result;
}

pub fn readAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Ring, buffer: []u8) !usize {
    var result: Ring.Result = .{
        .context_ptr = context_ptr,
    };

    try reactor_ptr.queue(.{
        .read = .{
            .FD = file_ptr.FD,
            .buffer = buffer,
            .offset = 0,
        },
    }, 0, @intFromPtr(&result));

    context_ptr.yield();

    if (result.value < 0) return Errno.toError(@enumFromInt(-result.value));

    return @intCast(result.value);
}

pub fn write(file_ptr: *File, buffer: []u8) !usize {
    const result: usize = syscall.write(file_ptr.FD, buffer);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result)) else return result;
}

pub fn writeAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Ring, buffer: []u8) !usize {
    var result: Ring.Result = .{
        .context_ptr = context_ptr,
    };

    try reactor_ptr.queue(.{
        .write = .{
            .FD = file_ptr.FD,
            .buffer = buffer,
            .offset = 0,
        },
    }, 0, @intFromPtr(&result));

    context_ptr.yield();

    if (result.value < 0) return Errno.toError(@enumFromInt(-result.value));

    return @intCast(result.value);
}
