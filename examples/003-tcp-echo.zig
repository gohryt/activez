const std = @import("std");
const log = std.log;
const activez = @import("activez");
const Context = activez.Context;
const Queue = activez.Queue;
const Listener = activez.Listener;

pub fn main() !void {
    const address = try std.net.Address.parseIp4("0.0.0.0", 8080);

    var listener: Listener = undefined;
    try listener.listen(address);

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

                const read: usize = @intCast(connection.read(&buffer) catch 0);
                _ = connection.write(buffer[0..read]) catch |err| {
                    std.log.err("can't write connection: {s}", .{@errorName(err)});
                    return;
                };
            }
        }
        std.log.info("{}", .{@as(usize, @intFromPtr(handler_ptr))});
    }
};

const ListenerContext = Context.From(ListenerHandler);
