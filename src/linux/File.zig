const std = @import("std");
const Context = @import("Context.zig");
const syscall = @import("syscall.zig");
const Errno = syscall.Errno;
const Reactor = @import("Reactor.zig");

directory_FD: i32 = 0,
FD: i32 = 0,

const File: type = @This();

pub const Stat: type = struct {
    statx: syscall.Statx,

    const Error = error{
        NoSize,
    };

    pub inline fn size(stat_ptr: *Stat) !u64 {
        if (stat_ptr.statx.mask.size) return stat_ptr.statx.size else return Error.NoSize;
    }
};

pub fn open(file_ptr: *File, path: [*:0]u8, flags: syscall.Openat.Flags, mode: syscall.Openat.Mode) !void {
    file_ptr.directory_FD = syscall.At.CWD_FD;

    const result: usize = syscall.openat(file_ptr.directory_FD, path, flags, mode);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));

    file_ptr.FD = @intCast(result);
}

pub fn openAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Reactor, path: [*:0]u8, flags: syscall.Openat.Flags, mode: syscall.Openat.Mode) !void {
    file_ptr.directory_FD = syscall.At.CWD_FD;

    var result: i32 = 0;
    const result_ptr: u64 = @intFromPtr(&result);

    std.log.info("result_ptr: {}", .{result_ptr});

    try reactor_ptr.queue(.{
        .openat = .{
            .directory_FD = file_ptr.directory_FD,
            .path = path,
            .flags = flags,
            .mode = mode,
        },
    }, 0, result_ptr);

    context_ptr.yield();

    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));

    file_ptr.FD = result;
}

pub fn close(file_ptr: *File) void {
    _ = syscall.close(file_ptr.FD);
}

// pub fn closeAsync(file: *File, context: *Context) void {
//     context.ring.queue(.{ .close = .{ .FD = file.FD } }, 0, 0) catch {};
// }

pub fn stat(file_ptr: *File, stat_ptr: *Stat, path: [*:0]u8, flags: syscall.At, mask: syscall.Statx.Mask) !void {
    const result: usize = result: {
        if (flags.empty_path) {
            break :result syscall.statx(file_ptr.FD, path, flags, mask, &stat_ptr.statx);
        } else {
            break :result syscall.statx(file_ptr.directory_FD, path, flags, mask, &stat_ptr.statx);
        }
    };

    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));
}

pub fn statAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Reactor, stat_ptr: *Stat, path: [*:0]u8, flags: syscall.At, mask: syscall.Statx.Mask) !void {
    var result: i32 = 0;
    const result_ptr: u64 = @intFromPtr(&result);

    if (flags.empty_path) {
        try reactor_ptr.queue(.{
            .statx = .{
                .directory_FD = file_ptr.FD,
                .path = path,
                .flags = flags,
                .mask = mask,
                .statx_ptr = &stat_ptr.statx,
            },
        }, 0, result_ptr);
    } else {
        try reactor_ptr.queue(.{
            .statx = .{
                .directory_FD = file_ptr.directory_FD,
                .path = path,
                .flags = flags,
                .mask = mask,
                .statx_ptr = &stat_ptr.statx,
            },
        }, 0, result_ptr);
    }

    context_ptr.yield();

    if (result < 0) return Errno.toError(@enumFromInt(-result));
}

pub fn read(file_ptr: *File, buffer: []u8) !usize {
    const result: usize = syscall.read(file_ptr.FD, buffer);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result)) else return result;
}

pub fn readAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Reactor, buffer: []u8) !usize {
    var result: i32 = 0;
    const result_ptr: u64 = @intFromPtr(&result);

    try reactor_ptr.queue(.{
        .read = .{
            .FD = file_ptr.FD,
            .buffer = buffer,
            .offset = 0,
        },
    }, 0, result_ptr);

    context_ptr.yield();

    if (result < 0) return Errno.toError(@enumFromInt(-result));

    return @intCast(result);
}

pub fn write(file_ptr: *File, buffer: []u8) !usize {
    const result: usize = syscall.write(file_ptr.FD, buffer);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result)) else return result;
}

pub fn writeAsync(file_ptr: *File, context_ptr: *Context, reactor_ptr: *Reactor, buffer: []u8) !usize {
    var result: i32 = 0;
    const result_ptr: u64 = @intFromPtr(&result);

    try reactor_ptr.queue(.{
        .write = .{
            .FD = file_ptr.FD,
            .buffer = buffer,
            .offset = 0,
        },
    }, 0, result_ptr);

    context_ptr.yield();

    if (result < 0) return Errno.toError(@enumFromInt(-result));

    return @intCast(result);
}
