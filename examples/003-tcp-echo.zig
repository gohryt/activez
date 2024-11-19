const std = @import("std");
const mem = std.mem;
const log = std.log;
const os = std.os;
const activez = @import("activez");
const Context = activez.Context;
const Queue = activez.Queue;
const Address = activez.Address;
const Listener = activez.Listener;

pub fn main() !void {
    var address_string: []u8 = @constCast("127.0.0.1:3000");

    if (os.argv.len == 2) {
        address_string = mem.span(os.argv[1]);
    }

    var address: Address = undefined;
    try address.parse(address_string);

    var listener: Listener = undefined;
    try listener.listen(&address.data, address.getLength());

    var listener_context: ListenerContext = undefined;
    try listener_context.init(.{ .listener = listener });

    try Queue.wait(&listener_context);
}

const ListenerHandler = struct {
    context: Context,
    listener: Listener,

    pub fn handle(handler_ptr: *ListenerHandler) void {
        while (true) {
            var connection: Listener.Connection = handler_ptr.listener.accept() catch |err| {
                std.log.err("can't accept connection: {s}", .{@errorName(err)});
                return;
            };
            defer {
                connection.close() catch |err| {
                    log.err("can't close connection: {s}", .{@errorName(err)});
                };
            }

            while (true) {
                var buffer: [4096]u8 = undefined;

                const read: usize = connection.read(&buffer) catch |err| {
                    log.err("can't read from connection: {s}", .{@errorName(err)});
                    return;
                };

                if (read == 0) {
                    break;
                }

                _ = connection.write(buffer[0..read]) catch |err| {
                    log.err("can't write to connection: {s}", .{@errorName(err)});
                    return;
                };
            }
        }
    }
};

const ListenerContext = Context.From(ListenerHandler);
