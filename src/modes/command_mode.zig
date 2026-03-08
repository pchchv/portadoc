const Self = @This();
const vaxis = @import("vaxis");
const Context = @import("../context.zig").Context;

const TextInput = vaxis.widgets.TextInput;

context: *Context,
text_input: TextInput,
history_prefix: ?[]const u8 = null,

pub fn init(context: *Context) Self {
    return .{
        .context = context,
        .text_input = TextInput.init(context.allocator),
    };
}

pub fn deinit(self: *Self) void {
    const win = self.context.vx.window();
    win.hideCursor();
    self.text_input.deinit();
    if (self.history_prefix) |history_prefix| self.context.allocator.free(history_prefix);
}
