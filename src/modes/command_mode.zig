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

pub fn drawCommandBar(self: *Self, win: vaxis.Window) void {
    const command_bar = win.child(.{
        .x_off = 0,
        .y_off = win.height - 1,
        .width = win.width,
        .height = 1,
    });
    _ = command_bar.print(&.{.{ .text = ":" }}, .{ .col_offset = 0 });
    self.text_input.draw(command_bar.child(.{ .x_off = 1 }));
}

pub fn executeCommand(self: *Self, cmd: []const u8) void {
    if (self.handleQuit(cmd)) return;
    if (self.handleGoToPage(cmd)) return;
    if (self.handleZoom(cmd)) return;
    if (self.handleScroll(cmd)) return;
}
