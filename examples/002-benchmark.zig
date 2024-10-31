const std = @import("std");
const log = std.log;
const activez = @import("activez");
const Context = activez.Context;
const Queue = activez.Queue;

const bounce_number: usize = 20_000_000;

pub fn main() !void {
    var contexts: [2]BenchmarkContext = undefined;

    try contexts[0].init(.{ .to_ptr = &contexts[1].handler.context });
    defer contexts[0].deinit();

    try contexts[1].init(.{ .to_ptr = &contexts[0].handler.context });
    defer contexts[1].deinit();

    const i: i128 = std.time.nanoTimestamp();

    try Queue.wait(@as([]BenchmarkContext, &contexts));

    const j: i128 = std.time.nanoTimestamp();

    log.err("ns/ctxswitch: {d}", .{@divFloor(j - i, bounce_number * 2)});
}

const BenchmarkHandler = struct {
    context: Context,
    to_ptr: *Context,

    pub fn handle(handler_ptr: *BenchmarkHandler) void {
        for (0..bounce_number) |_| {
            handler_ptr.context.yieldTo(&handler_ptr.context);
        }
    }
};

const BenchmarkContext = Context.From(BenchmarkHandler);
