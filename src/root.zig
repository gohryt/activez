pub usingnamespace switch (@import("builtin").target.os.tag) {
    .linux => @import("linux/root.zig"),
    else => {
        @compileError("OS not supported");
    },
};
