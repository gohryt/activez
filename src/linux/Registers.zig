const Registers = @This();

data: [8]usize,

pub inline fn swap(registers_ptr: *Registers, to_ptr: *Registers) void {
    registers_swap(registers_ptr, to_ptr);
}

const architecture = switch (@import("builtin").target.cpu.arch) {
    .x86_64 => @embedFile("Registers_amd64.s"),
    else => {
        @compileError("CPU architecture not supported");
    },
};

comptime {
    asm (architecture);
}

extern fn registers_swap(from_ptr: *Registers, to_ptr: *Registers) callconv(.SysV) void;
