const Registers = @This();

data: [8]usize,

const architecture = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @embedFile("Registers_amd64.s"),
    else => {
        @compileError("CPU architecture not supported");
    },
};

comptime {
    asm (architecture);
}
