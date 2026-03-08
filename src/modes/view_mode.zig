const Self = @This();
const vaxis = @import("vaxis");
const Context = @import("../context.zig").Context;

context: *Context,

pub const KeyAction = struct {
    codepoint: u21,
    mods: vaxis.Key.Modifiers,
    handler: *const fn (*Context) void,
};

pub fn init(context: *Context) Self {
    return .{
        .context = context,
    };
}
