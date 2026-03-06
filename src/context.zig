const std = @import("std");
const vaxis = @import("vaxis");
const fzwatch = @import("fzwatch");

pub const ReloadIndicatorState = enum { idle, reload, watching };
pub const Event = union(enum) {
    key_press: vaxis.Key,
    mouse: vaxis.Mouse,
    winsize: vaxis.Winsize,
    file_changed,
    reload_done: usize,
};

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

    pub fn deinit(self: *Self) void {
        switch (self.current_mode) {
            .command => |*state| state.deinit(),
            .view => {},
        }

        if (self.watcher) |*w| {
            w.stop();
            if (self.watcher_thread) |thread| {
                thread.join();
            }
            w.deinit();
        }

        if (self.page_info_text.len > 0) {
            self.allocator.free(self.page_info_text);
        }

        self.reload_indicator_timer.deinit();
        self.history.deinit();
        self.cache.deinit();
        self.document_handler.deinit();
        self.vx.deinit(self.allocator, self.tty.writer());
        self.tty.deinit();
        self.config.deinit();
        self.allocator.destroy(self.config);
        self.arena.deinit();
        self.allocator.free(self.buf);
    }

    fn callback(context: ?*anyopaque, event: fzwatch.Event) void {
        switch (event) {
            .modified => {
                const loop = @as(*vaxis.Loop(Event), @ptrCast(@alignCast(context.?)));
                loop.postEvent(Event.file_changed);
            },
        }
    }

    fn watcherWorker(self: *Self, watcher: *fzwatch.Watcher) !void {
        try watcher.start(.{ .latency = self.config.file_monitor.latency });
    }
};
