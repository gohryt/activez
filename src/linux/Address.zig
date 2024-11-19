const syscall = @import("syscall.zig");

const Address = @This();

data: syscall.Socket.Address,

// example of fill
// var address: Address = .{ .data = .{ .family = .internet4, .data = .{ .internet4 = .{ .port = @byteSwap(port), .address = .{ 127, 0, 0, 1 } } } } };

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

pub fn parseIPv4(address_ptr: *Address, from: []u8) !void {
    var i: u16 = 0;
    var j: u16 = 0;

    for (from) |byte| {
        switch (byte) {
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => {
                j = j * 10 + byte - '0';
            },
            '.', ':' => {
                switch (i) {
                    0, 1, 2, 3 => {
                        address_ptr.data.data.internet4.address[i] = @intCast(j);

                        i += 1;
                        j = 0;
                    },
                    else => return ParseError.BadInput,
                }
            },
            else => return ParseError.BadInput,
        }
    }

    if (i != 4) return ParseError.BadInput;

    address_ptr.data.family = .internet4;
    address_ptr.data.data.internet4.port = @byteSwap(j);
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
