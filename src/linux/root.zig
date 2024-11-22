pub const Context = @import("Context.zig");
pub const Queue = @import("Queue.zig");
pub const Ring = @import("Ring.zig");
pub const File = @import("File.zig");
pub const Address = @import("Address.zig");
pub const Listener = @import("Listener.zig");
pub const syscall = @import("syscall.zig");

var stdin: File = .{
    .directory_FD = 0,
    .FD = 0,
};

var stdout: File = .{
    .directory_FD = 0,
    .FD = 1,
};

var stderr: File = .{
    .directory_FD = 0,
    .FD = 2,
};

pub fn getStdinPtr() *File {
    return &stdin;
}

pub fn getStdoutPtr() *File {
    return &stdout;
}

pub fn getStderrPtr() *File {
    return &stderr;
}
