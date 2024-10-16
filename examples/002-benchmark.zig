const std = @import("std");
const mem = std.mem;
const log = std.log;
const os = std.os;
const activez = @import("activez");
const Queue = activez.Queue;
const ContextWith = activez.ContextWith;
const Context = activez.Context;

const GPA = std.heap.GeneralPurposeAllocator(.{
    .thread_safe = true,
});

const bounce_number: usize = 20_000_000;

pub fn main() !void {
    var instance: GPA = GPA.init;
    defer {
        if (instance.deinit() == .leak) {
            log.err("allocator deinit check == leak", .{});
        }
    }

    const allocator: mem.Allocator = instance.allocator();

    var contexts: [2]BenchmarkContext = undefined;

    try contexts[0].init(allocator, .{ .to_ptr = &contexts[1].handler.context });
    defer contexts[0].deinit(allocator);

    try contexts[1].init(allocator, .{ .to_ptr = &contexts[0].handler.context });
    defer contexts[1].deinit(allocator);

    const i: i128 = std.time.nanoTimestamp();

    try Queue.wait(@as([]BenchmarkContext, &contexts));

    const j: i128 = std.time.nanoTimestamp();

    log.err("ns/ctxswitch: {d}", .{@divFloor(j - i, bounce_number * 2)});
}

const BenchmarkHandler = extern struct {
    context: Context,
    to_ptr: *Context,

    pub fn handle(handler_ptr: *BenchmarkHandler) void {
        for (0..bounce_number) |_| {
            handler_ptr.context.swap(handler_ptr.to_ptr);
        }
    }
};

const BenchmarkContext = Context.From(BenchmarkHandler);
