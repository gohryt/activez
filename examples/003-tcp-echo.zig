const std = @import("std");
const log = std.log;
const activez = @import("activez");
const Context = activez.Context;
const Queue = activez.Queue;
const Listener = activez.Listener;

pub fn main() !void {
    const address = try std.net.Address.parseIp4("0.0.0.0", 8080);
    var a: activez.linux.syscall.SocketAddress = @bitCast(address.any);

    var listener: Listener = undefined;
    try listener.listen(&a, address.getOsSockLen());

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
