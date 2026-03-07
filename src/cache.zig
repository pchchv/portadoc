const Self = @This();
const std = @import("std");
const vaxis = @import("vaxis");
const Config = @import("config/config.zig");

pub const CachedImage = struct { image: vaxis.Image };
pub const Key = struct {
    colorize: bool,
    page: u16,
    width_mode: bool,
    zoom: u32,
    x_offset: i32,
    y_offset: i32,
};

const Node = struct {
    key: Key,
    value: CachedImage,
    prev: ?*Node,
    next: ?*Node,
};

allocator: std.mem.Allocator,
map: std.AutoHashMap(Key, *Node),
head: ?*Node,
tail: ?*Node,
config: *Config,
lru_size: u16,
vx: vaxis.Vaxis,
tty: *const vaxis.Tty,

pub fn init(
    allocator: std.mem.Allocator,
    config: *Config,
    vx: vaxis.Vaxis,
    tty: *const vaxis.Tty,
) Self {
    return .{
        .allocator = allocator,
        .map = std.AutoHashMap(Key, *Node).init(allocator),
        .head = null,
        .tail = null,
        .config = config,
        .lru_size = config.cache.lru_size,
        .vx = vx,
        .tty = tty,
    };
}

pub fn deinit(self: *Self) void {
    var current = self.head;
    while (current) |node| {
        const next = node.next;

        self.allocator.destroy(node);

        current = next;
    }

    self.map.deinit();
}
