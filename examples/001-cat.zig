const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const log = std.log;
const os = std.os;
const activez = @import("activez");
const Context = activez.Context;
const Queue = activez.Queue;
const Reactor = activez.Reactor;
const File = activez.File;
const getStdout = activez.getStdout;

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
        for (contexts) |*context_ptr| {
            context_ptr.deinit();
        }

        allocator.free(contexts);
    }

    var reactor: Reactor = try Reactor.init(@intCast(os.argv.len), .{Reactor.SQPoll{ .thread_idle = 100 }});
    defer reactor.deinit();

    var done: usize = 0;

    for (os.argv[1..], 0..) |arg, i| {
        try contexts[i].init(.{ .reactor_ptr = &reactor, .allocator = allocator, .path = arg, .done = &done });
    }

    var reactor_context: ReactorContext = undefined;
    try reactor_context.init(.{ .reactor_ptr = &reactor, .allocator = allocator, .size = os.argv.len - 1, .done = &done });

    try Queue.wait(.{ contexts, &reactor_context });
}

const ReactorHandler = struct {
    context: Context,
    reactor_ptr: *Reactor,
    allocator: Allocator,
    size: usize,
    done: *usize,

    pub fn handle(handler_ptr: *ReactorHandler) void {
        var CQEs: []Reactor.CQE = handler_ptr.allocator.alloc(Reactor.CQE, handler_ptr.size) catch |err| {
            log.err("can't wait events: {s}", .{@errorName(err)});
            return;
        };
        defer handler_ptr.allocator.free(CQEs);

        while (handler_ptr.done.* != handler_ptr.size) {
            const ready: usize = handler_ptr.reactor_ptr.submit() catch |err| {
                log.err("can't wait events: {s}", .{@errorName(err)});
                return;
            };

            handler_ptr.reactor_ptr.peekCQEs(CQEs[0..ready]) catch |err| {
                log.err("can't peek events: {s}", .{@errorName(err)});
                return;
            };

            handler_ptr.reactor_ptr.advanceCQ(@intCast(ready));
            handler_ptr.context.yield();
        }
    }
};

const ReactorContext = Context.From(ReactorHandler);

const CatHandler = struct {
    context: Context,
    reactor_ptr: *Reactor,
    allocator: Allocator,
    path: [*:0]u8,
    done: *usize,

    pub fn handle(handler_ptr: *CatHandler) void {
        var file: File = undefined;

        file.open(handler_ptr.path, .{}, .{}) catch |err| {
            log.err("can't open file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };
        defer file.close();

        var stat: File.Stat = undefined;

        file.stat(&stat, handler_ptr.path, .{ .size = true }) catch |err| {
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

        const read: usize = file.read(buffer) catch |err| {
            log.err("can't read file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };

        var stdout: File = getStdout();

        const wrote: usize = stdout.write(buffer[0..read]) catch |err| {
            log.err("can't write file {s}: {s}", .{ handler_ptr.path, @errorName(err) });
            return;
        };

        if (wrote != read) {
            log.err("{s}: wrote less then read", .{handler_ptr.path});
        }

        handler_ptr.done.* += 1;
    }
};

const CatContext = Context.From(CatHandler);
