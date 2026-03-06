const std = @import("std");
const vaxis = @import("vaxis");
const fzwatch = @import("fzwatch");

pub const ReloadIndicatorState = enum { idle, reload, watching };

pub const Context = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    should_quit: bool,
    tty: vaxis.Tty,
    vx: vaxis.Vaxis,
    mouse: ?vaxis.Mouse,
    page_info_text: []u8,
    current_page: ?vaxis.Image,
    watcher: ?fzwatch.Watcher,
    watcher_thread: ?std.Thread,
    reload_page: bool,
    should_check_cache: bool,
    current_reload_indicator_state: ReloadIndicatorState,
    reload_indicator_active: bool,
    buf: []u8,
};
