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

pub fn main() !void {
    var instance: GPA = GPA.init;
    defer {
        if (instance.deinit() == .leak) {
            log.err("allocator deinit check == leak", .{});
        }
    }

    const allocator: mem.Allocator = instance.allocator();

    if (os.argv.len < 2) {
        return log.err("Usage: {s} [file name] <[file name] ...>", .{os.argv[0]});
    }

    var parallel: bool = false;

    const contexts: []CatContext = try allocator.alloc(CatContext, (os.argv.len - 1));
    defer {
        for (contexts) |*context_ptr| {
            context_ptr.deinit(allocator);
        }

        allocator.free(contexts);
    }

    var contexts_len: usize = 0;

    for (os.argv[1..]) |arg| {
        if (std.mem.eql(u8, "--parallel", mem.span(arg))) {
            parallel = true;
        } else {
            try contexts[contexts_len].init(allocator, .{ .path = arg });
            contexts_len += 1;
        }
    }

    try Queue.wait(contexts[0..contexts_len]);
}

const CatContext = ContextWith(struct {
    path: [*:0]u8,

    const Self = @This();

    pub fn handle(context_ptr: *Context, self_ptr: *Self) void {
        log.err("path: calculating", .{});
        context_ptr.yield();
        log.err("path: {s}", .{self_ptr.path});
        context_ptr.yield();
        log.err("path: calculated", .{});
    }
});
