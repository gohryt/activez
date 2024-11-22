const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const log = std.log;
const os = std.os;
const activez = @import("activez");
const Context = activez.Context;
const Queue = activez.Queue;
const Ring = activez.linux.Ring;
const File = activez.File;

const GPA = std.heap.GeneralPurposeAllocator(.{
    .thread_safe = true,
});

pub fn main() !void {
    var instance: GPA = GPA.init;
    defer {
        if (instance.deinit() == .leak) {
            log.err("allocator deinit check == leak", .{});
        }
    }

    const allocator: Allocator = instance.allocator();

    if (os.argv.len < 2) {
        return log.err("Usage: {s} [file name] <[file name] ...>", .{os.argv[0]});
    }

    const contexts: []CatContext = try allocator.alloc(CatContext, (os.argv.len - 1));
    defer {
        for (contexts) |*context_ptr| context_ptr.deinit();
        allocator.free(contexts);
    }

    var ring: Ring = undefined;
    try ring.init(@intCast(os.argv.len - 1), .{Ring.SQPoll{ .thread_idle = 100 }});
    defer ring.deinit();

    for (os.argv[1..], 0..) |arg, i| {
        try contexts[i].init(.{ .ring_ptr = &ring, .allocator = allocator, .path = arg });
    }

    var ring_context: RingContext = undefined;
    try ring_context.init(.{ .ring_ptr = &ring });
    defer ring_context.deinit();

    try Queue.wait(.{ contexts, &ring_context });
}

const RingContext = Context.From(struct {
    context: Context,
    ring_ptr: *Ring,

    const RingHandler = @This();

    pub fn handle(handler_ptr: *RingHandler) void {
        while (@atomicLoad(usize, &handler_ptr.ring_ptr.queued, .acquire) != 0) {
            const ready: usize = handler_ptr.ring_ptr.submitAndWait(1) catch |err| {
                log.err("can't wait events: {s}", .{@errorName(err)});
                return;
            };

            const CQEs: []Ring.CQE = handler_ptr.ring_ptr.peekCQEs(@intCast(ready)) catch |err| {
                log.err("can't peek events: {s}", .{@errorName(err)});
                return;
            };

            for (CQEs) |*CQE_ptr| {
                @as(*Ring.Result, @ptrFromInt(CQE_ptr.user_data)).value = CQE_ptr.result;
            }

            handler_ptr.ring_ptr.advanceCQ(@intCast(CQEs.len));
            handler_ptr.context.yield();
        }
    }
});

const CatContext = Context.From(struct {
    context: Context,
    ring_ptr: *Ring,
    allocator: Allocator,
    path: [*:0]u8,

    const CatHandler = @This();

    pub fn handle(handler_ptr: *CatHandler) void {
        var file: File = undefined;

        file.openAsync(&handler_ptr.context, handler_ptr.ring_ptr, handler_ptr.path, .{}, .{}) catch |err| {
            log.err("can't open file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };
        defer {
            file.closeAsync(&handler_ptr.context, handler_ptr.ring_ptr) catch |err| {
                log.err("can't close file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            };
        }

        var stat: File.Stat = undefined;

        file.statAsync(&handler_ptr.context, handler_ptr.ring_ptr, &stat, @constCast(""), .sync_as_stat_empty_path, .{ .size = true }) catch |err| {
            log.err("can't load file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };

        const size: usize = stat.size() catch |err| {
            log.err("can't load file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };

        const buffer: []u8 = handler_ptr.allocator.alloc(u8, size) catch |err| {
            log.err("can't read file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };
        defer handler_ptr.allocator.free(buffer);

        const read: usize = file.readAsync(&handler_ptr.context, handler_ptr.ring_ptr, buffer) catch |err| {
            log.err("can't read file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };

        const wrote: usize = activez.getStdoutPtr().writeAsync(&handler_ptr.context, handler_ptr.ring_ptr, buffer[0..read]) catch |err| {
            log.err("can't write file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };

        if (wrote != read) {
            log.err("{s}: wrote less then read", .{handler_ptr.path});
        }
    }
});
