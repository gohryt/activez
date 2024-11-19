const std = @import("std");
const syscall = @import("syscall.zig");

const Address = @This();

data: syscall.Socket.Address,

pub const ParseError = error{
    UnknownIPType,
    BadInput,
};

pub fn parse(address: *Address, from: []u8) !void {
    for (from) |byte| {
        switch (byte) {
            '.' => return address.parseIPv4(from),
            ':' => return address.parseIPv6(from),
            else => {},
        }
    }

    return ParseError.UnknownIPType;
}

const ParseIPv4At = enum {
    IP,
    Port,
};

pub fn parseIPv4(address_ptr: *Address, from: []u8) !void {
    var address: [4]u8 = undefined;

    var i: usize = 0;
    var j: usize = 0;

    for (from) |byte| {
        if ('0' <= byte and byte <= '9') {
            j = j * 10 + byte - '0';
        } else if ((byte == '.' or byte == ':') and j < 256) {
            address[i] = @intCast(j);
            j = 0;
            i = i + 1;
        } else return ParseError.BadInput;
    }

    if (j > std.math.maxInt(u16)) return ParseError.BadInput;

    const port: u16 = @intCast(j);

    address_ptr.data = .{ .family = .internet4, .data = .{ .internet4 = .{
        .port = @byteSwap(port),
        .address = address,
    } } };
}

pub fn parseIPv6(address: *Address, from: []u8) !void {
    _ = address;
    _ = from;
}

pub fn getLength(address: *Address) u32 {
    return switch (address.data.family) {
        .internet4 => @sizeOf(syscall.Socket.Address.Family) + @sizeOf(syscall.Socket.Address.Internet4),
        else => unreachable,
    };
}
