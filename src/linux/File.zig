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

    try reactor_ptr.queue(.{
        .openat = .{
            .directory_FD = file_ptr.directory_FD,
            .path = path,
            .flags = flags,
            .mode = mode,
        },
    }, 0, 0);

    context_ptr.yield();

    file_ptr.FD = @intCast(0);
}

pub fn close(file_ptr: *File) void {
    _ = syscall.close(file_ptr.FD);
}

pub fn stat(file_ptr: *File, stat_ptr: *Stat, path: [*:0]u8, mask: syscall.Statx.Mask) !void {
    const result: usize = syscall.statx(file_ptr.directory_FD, path, .sync_as_stat, mask, &stat_ptr.statx);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));
}

pub fn read(file_ptr: *File, buffer: []u8) !usize {
    const result: usize = syscall.read(file_ptr.FD, buffer);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result)) else return result;
}

pub fn write(file_ptr: *File, buffer: []u8) !usize {
    const result: usize = syscall.write(file_ptr.FD, buffer);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result)) else return result;
}

// pub fn closeAsync(file: *File, context: *Context) void {
//     context.ring.queue(.{ .close = .{ .FD = file.FD } }, 0, 0) catch {};
// }

// pub fn statAsync(file: *File, context: *Context, mask: Stat.Mask) !*Stat {
//     const stat_ptr: *Stat = try context.allocator.create(Stat);

//     try context.ring.queue(.{ .statx = .{
//         .directory_FD = syscall.at_FD_CWD,
//         .path = file.path,
//         .flags = syscall.at_statx_sync_as_stat,
//         .mask = mask,
//         .statx_ptr = stat_ptr,
//     } }, 0, 0);

//     return stat_ptr;
// }
