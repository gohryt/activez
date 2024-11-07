const std = @import("std");
const Context = @import("Context.zig");
const syscall = @import("syscall.zig");
const Errno = syscall.Errno;
const Ring = @import("Ring.zig");

FD: i32 = 0,
address: std.net.Address,

const Listener = @This();

pub const init: Listener = .{};

pub fn listen(listener_ptr: *Listener, address: std.net.Address) !void {
    var result: usize = syscall.socket(2, 1, 0);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));

    const FD: i32 = @intCast(result);

    result = syscall.bind(FD, address);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));

    result = syscall.listen(FD, 512);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));

    listener_ptr.* = .{ .FD = FD, .address = address };
}

pub fn close(listener_ptr: *Listener) !void {
    const result: usize = syscall.close(listener_ptr.FD);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));
}

pub fn accept(listener_ptr: *Listener) !Connection {
    var len: u32 = listener_ptr.address.getOsSockLen();
    const result: usize = syscall.accept(listener_ptr.FD, &listener_ptr.address.any, &len, 0);
    if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));

    return .{
        .FD = @intCast(result),
    };
}

pub const Connection: type = struct {
    FD: i32,

    pub fn close(connection_ptr: *Connection) !void {
        const result: usize = syscall.close(connection_ptr.FD);
        if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));
    }

    pub fn read(connection_ptr: *Connection, buffer: []u8) !i32 {
        const result: usize = syscall.recv(connection_ptr.FD, buffer, 0, null, null);
        if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));
        return @intCast(result);
    }

    pub fn write(connection_ptr: *Connection, buffer: []u8) !i32 {
        const result: usize = syscall.send(connection_ptr.FD, buffer, 0, null, 0);
        if (result > syscall.result_max) return Errno.toError(@enumFromInt(0 -% result));
        return @intCast(result);
    }
};
