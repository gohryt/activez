pub const Context = @import("Context.zig");
pub const Queue = @import("Queue.zig");
pub const File = @import("File.zig");

pub const stdin_FD: i32 = 0;
pub const stdout_FD: i32 = 1;
pub const stderr_FD: i32 = 2;

pub fn getStdin() File {
    return .{
        .FD = stdin_FD,
    };
}

pub fn getStdout() File {
    return .{
        .FD = stdout_FD,
    };
}

pub fn getStderr() File {
    return .{
        .FD = stderr_FD,
    };
}
