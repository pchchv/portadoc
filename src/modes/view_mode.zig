const Self = @This();
const Context = @import("../context.zig").Context;

context: *Context,

pub fn init(context: *Context) Self {
    return .{
        .context = context,
    };
}
