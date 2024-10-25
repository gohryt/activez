const std = @import("std");
const syscall = @import("syscall.zig");
const Context = @import("Context.zig");

directory_FD: i32 = 0,
FD: i32 = 0,

const File: type = @This();

pub const Stat: type = struct {
    statx: syscall.Statx,

    pub const Mask: type = syscall.Statx.Mask;

    pub fn size(stat_ptr: *Stat) u64 {
        return stat_ptr.statx.size;
    }
};

pub fn open(file_ptr: *File, path: [*:0]u8, flags: syscall.Openat.Flags, mode: syscall.Openat.Mode) !void {
    file_ptr.directory_FD = syscall.at_FD_CWD;
    file_ptr.FD = try syscall.open(file_ptr.directory_FD, path, flags, mode);
}

pub fn openAsync(file_ptr: *File, context_ptr: *Context, path: [*:0]u8, flags: syscall.Openat.Flags, mode: syscall.Openat.Mode) !void {
    file_ptr.directory_FD = syscall.at_FD_CWD;

    try context_ptr.ring.queue(.{
        .openat = .{
            .directory_FD = file_ptr.directory_FD,
            .path = path,
            .flags = flags,
            .mode = mode,
        },
    }, 0, 0);

    const result: isize = @bitCast(context_ptr.yieldWithResult(usize));

    if (result < 0) {
        return syscall.Error.Openat;
    }

    file_ptr.FD = @intCast(result);
}

pub fn close(file_ptr: *File) void {
    syscall.close(file_ptr.FD) catch {};
}

pub fn stat(file_ptr: *File, stat_ptr: *Stat, path: [*:0]u8, mask: Stat.Mask) !void {
    _ = try syscall.statx(file_ptr.directory_FD, path, syscall.at_statx_sync_as_stat, mask, &stat_ptr.statx);
}

pub fn read(file_ptr: *File, buffer: []u8) !i32 {
    return try syscall.read(file_ptr.FD, buffer);
}

pub fn write(file_ptr: *File, buffer: []u8) !i32 {
    return try syscall.write(file_ptr.FD, buffer);
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
