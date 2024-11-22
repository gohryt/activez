const Context = @import("Context.zig");
const Ring = @import("Ring.zig");

const RingHandler = @This();

context: Context,
ring: Ring,

pub fn handle(handler_ptr: *RingHandler) void {
    _ = handler_ptr;
}
