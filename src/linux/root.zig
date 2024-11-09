pub const Context = @import("Context.zig");
pub const Queue = @import("Queue.zig");
pub const Reactor = @import("Ring.zig");
pub const File = @import("File.zig");
pub const Listener = @import("Listener.zig");
pub const syscall = @import("syscall.zig");

pub const stdin_FD: i32 = 0;
pub const stdout_FD: i32 = 1;
pub const stderr_FD: i32 = 2;

pub fn getStdin() File {
    return .{
        .directory_FD = 0,
        .FD = stdin_FD,
    };
}

pub fn getStdout() File {
    return .{
        .directory_FD = 0,
        .FD = stdout_FD,
    };
}

pub fn getStderr() File {
    return .{
        .directory_FD = 0,
        .FD = stderr_FD,
    };
}
