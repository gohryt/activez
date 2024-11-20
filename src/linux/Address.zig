const std = @import("std");
const math = std.math;
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
            else => {},
        }
    }

    return ParseError.UnknownIPType;
}

pub fn parseIPv4(address_ptr: *Address, from: []u8) !void {
    var address: [4]u8 = undefined;

    var i: usize = 0;
    var j: usize = 0;

    for (from) |byte| {
        if ('0' <= byte and byte <= '9') {
            j = j * 10 + byte - '0';
        } else if ((byte == '.' or byte == ':') and j <= math.maxInt(u8)) {
            address[i] = @intCast(j);
            j = 0;
            i = i + 1;
        } else return ParseError.BadInput;
    }

    if (i == 4 and j <= math.maxInt(u16)) {
        const port: u16 = @intCast(j);

        address_ptr.data = .{ .family_id = .internet4, .family = .{ .internet4 = .{
            .port = @byteSwap(port),
            .address = address,
        } } };
    } else return ParseError.BadInput;
}

pub fn getLength(address: *Address) u32 {
    return switch (address.data.family_id) {
        .internet4 => @sizeOf(syscall.Socket.Address.Family) + @sizeOf(syscall.Socket.Address.Internet4),
        else => unreachable,
    };
}
