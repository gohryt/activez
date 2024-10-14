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

    try contexts[0].init(allocator, .{ .to_ptr = &contexts[1].context });
    defer contexts[0].deinit(allocator);

    try contexts[1].init(allocator, .{ .to_ptr = &contexts[0].context });
    defer contexts[1].deinit(allocator);

    const i: i128 = std.time.nanoTimestamp();

    try Queue.wait(@as([]BenchmarkContext, &contexts));

    const j: i128 = std.time.nanoTimestamp();

    log.err("ns/ctxswitch: {d}", .{@divFloor(j - i, bounce_number * 2)});
}

const BenchmarkContext = ContextWith(extern struct {
    to_ptr: *Context,

    const Self = @This();

    pub fn handle(context_ptr: *Context, self_ptr: *Self) void {
        for (0..bounce_number) |_| {
            context_ptr.swap(self_ptr.to_ptr);
        }
    }
});
