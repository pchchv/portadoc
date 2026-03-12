const Self = @This();
const std = @import("std");
const vaxis = @import("vaxis");
const Config = @import("../config/config.zig");
const Event = @import("../context.zig").Event;

const Timer = std.time.Timer;

mutex: std.Thread.Mutex,
condition: std.Thread.Condition,
thread: ?std.Thread,
should_quit: bool,
loop: ?*vaxis.Loop(Event),
reload_indicator_duration_ns: u64,
reload_timer: ?Timer,
generation: usize,
pending: bool,
config: *Config,

pub fn init(config: *Config) Self {
    return .{
        .mutex = std.Thread.Mutex{},
        .condition = std.Thread.Condition{},
        .thread = null,
        .should_quit = false,
        .loop = null,
        .reload_indicator_duration_ns = 0,
        .reload_timer = null,
        .generation = 0,
        .pending = false,
        .config = config,
    };
}

pub fn deinit(self: *Self) void {
    self.mutex.lock();
    self.should_quit = true;
    self.condition.signal();
    self.mutex.unlock();
    if (self.thread) |thread| {
        thread.join();
        self.thread = null;
    }
}

pub fn notifyChange(self: *Self) void {
    self.mutex.lock();
    self.generation += 1;
    if (self.reload_timer) |*timer| timer.reset();
    self.pending = true;
    self.condition.signal();
    self.mutex.unlock();
}
