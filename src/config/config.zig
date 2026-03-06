const std = @import("std");
const vaxis = @import("vaxis");

pub const KeyMap = struct {
    next: vaxis.Key = .{ .codepoint = 'n' },
    prev: vaxis.Key = .{ .codepoint = 'p' },
    scroll_up: vaxis.Key = .{ .codepoint = 'k' },
    scroll_down: vaxis.Key = .{ .codepoint = 'j' },
    scroll_left: vaxis.Key = .{ .codepoint = 'h' },
    scroll_right: vaxis.Key = .{ .codepoint = 'l' },
    zoom_in: vaxis.Key = .{ .codepoint = 'i' },
    zoom_out: vaxis.Key = .{ .codepoint = 'o' },
    width_mode: vaxis.Key = .{ .codepoint = 'w' },
    colorize: vaxis.Key = .{ .codepoint = 'z' },
    quit: vaxis.Key = .{ .codepoint = 'c', .mods = .{ .ctrl = true } },
    full_screen: vaxis.Key = .{ .codepoint = 'f' },
    enter_command_mode: vaxis.Key = .{ .codepoint = ':' },
    exit_command_mode: vaxis.Key = .{ .codepoint = vaxis.Key.escape },
    execute_command: vaxis.Key = .{ .codepoint = vaxis.Key.enter },
    history_back: vaxis.Key = .{ .codepoint = vaxis.Key.up },
    history_forward: vaxis.Key = .{ .codepoint = vaxis.Key.down },

    pub fn parse(val: std.json.Value, allocator: std.mem.Allocator) KeyMap {
        var keymap = KeyMap{};
        if (val != .object) return keymap;

        inline for (std.meta.fields(KeyMap)) |key| {
            @field(keymap, key.name) = parseKeyBinding(val.object, key.name, allocator, @field(
                keymap,
                key.name,
            ));
        }

        return keymap;
    }
};

pub const FileMonitor = struct {
    enabled: bool = true,
    // amount of time in seconds to wait in between polling for file changes
    latency: f16 = 0.1,
    reload_indicator_duration: f16 = 1.0,

    pub fn parse(val: std.json.Value, allocator: std.mem.Allocator) FileMonitor {
        var file_monitor = FileMonitor{};
        if (val != .object) return file_monitor;

        file_monitor.enabled = parseType(
            bool,
            val.object,
            "enabled",
            allocator,
            file_monitor.enabled,
        );
        file_monitor.latency = parseType(
            f16,
            val.object,
            "latency",
            allocator,
            file_monitor.latency,
        );
        file_monitor.reload_indicator_duration = parseType(
            f16,
            val.object,
            "reload_indicator_duration",
            allocator,
            file_monitor.reload_indicator_duration,
        );

        return file_monitor;
    }
};

pub const General = struct {
    colorize: bool = false,
    white: i32 = 0x000000,
    black: i32 = 0xffffff,
    // size of the pdf
    // 1 is the whole window
    size: f32 = 1.0,
    // percentage
    zoom_step: f32 = 1.25,
    zoom_min: f32 = 1.0,
    // pixels
    scroll_step: f32 = 100.0,
    // seconds
    retry_delay: f32 = 0.2,
    timeout: f32 = 5.0,
    // resolution
    detect_dpi: bool = true,
    dpi: f32 = 96.0,
    // whole number (possibly 0)
    history: u32 = 1000,

    pub fn parse(val: std.json.Value, allocator: std.mem.Allocator) General {
        var general = General{};
        if (val != .object) return general;

        general.colorize = parseType(bool, val.object, "colorize", allocator, general.colorize);
        if (val.object.get("white")) |white| {
            if (parseRGB(white, allocator)) |rgb| {
                general.white = @intCast(
                    (@as(u32, rgb[0]) << 16) | (@as(u32, rgb[1]) << 8) | @as(u32, rgb[2]),
                );
            }
        }

        if (val.object.get("black")) |black| {
            if (parseRGB(black, allocator)) |rgb| {
                general.black = @intCast(
                    (@as(u32, rgb[0]) << 16) | (@as(u32, rgb[1]) << 8) | @as(u32, rgb[2]),
                );
            }
        }

        general.size = parseType(f32, val.object, "size", allocator, general.size);
        general.zoom_step = parseType(f32, val.object, "zoom_step", allocator, general.zoom_step);
        general.zoom_min = parseType(f32, val.object, "zoom_min", allocator, general.zoom_min);
        general.scroll_step = parseType(f32, val.object, "scroll_step", allocator, general.scroll_step);
        general.retry_delay = parseType(f32, val.object, "retry_delay", allocator, general.retry_delay);
        general.timeout = parseType(f32, val.object, "timeout", allocator, general.timeout);
        general.detect_dpi = parseType(bool, val.object, "detect_dpi", allocator, general.detect_dpi);
        general.dpi = parseType(f32, val.object, "dpi", allocator, general.dpi);
        general.history = parseType(u32, val.object, "history", allocator, general.history);
        return general;
    }
};

pub const Cache = struct {
    enabled: bool = true,
    // number of pages to cache
    lru_size: u16 = 10,

    pub fn parse(val: std.json.Value, allocator: std.mem.Allocator) Cache {
        var cache = Cache{};
        if (val != .object) return cache;

        cache.enabled = parseType(bool, val.object, "enabled", allocator, cache.enabled);
        // XXX temporary change to u16 from usize due to bug in std
        cache.lru_size = parseType(u16, val.object, "lru_size", allocator, cache.lru_size);
        return cache;
    }
};

pub const StatusBar = struct {
    pub const StyledItem = struct {
        text: []const u8,
        style: vaxis.Cell.Style,
    };
    pub const ModeAwareItem = struct {
        view: StyledItem,
        command: StyledItem,
    };
    pub const ReloadAwareItem = struct {
        idle: StyledItem,
        reload: StyledItem,
        watching: StyledItem,
    };
    pub const Item = union(enum) {
        styled: StyledItem,
        mode_aware: ModeAwareItem,
        reload_aware: ReloadAwareItem,
    };
};

fn parseType(comptime T: type, obj: std.json.ObjectMap, key: []const u8, allocator: std.mem.Allocator, fallback: T) T {
    if (obj.get(key)) |raw_key| {
        return std.json.innerParseFromValue(T, allocator, raw_key, .{}) catch fallback;
    }
    return fallback;
}

fn parseKeyBinding(obj: std.json.ObjectMap, name: []const u8, allocator: std.mem.Allocator, fallback: vaxis.Key) vaxis.Key {
    const val = obj.get(name) orelse return fallback;
    if (val != .object) return fallback;

    const key_str = parseType([]const u8, val.object, "key", allocator, "");
    if (key_str.len == 0) return fallback;

    var binding = fallback;
    binding.codepoint = vaxis.Key.name_map.get(key_str) orelse @as(u21, key_str[0]);

    var mods = vaxis.Key.Modifiers{};
    const modifiers = val.object.get("modifiers") orelse return binding;
    if (modifiers != .array) return binding;
    for (modifiers.array.items) |mod| {
        if (mod != .string) continue;
        if (std.mem.eql(u8, mod.string, "shift")) mods.shift = true;
        if (std.mem.eql(u8, mod.string, "alt")) mods.alt = true;
        if (std.mem.eql(u8, mod.string, "ctrl")) mods.ctrl = true;
        if (std.mem.eql(u8, mod.string, "super")) mods.super = true;
        if (std.mem.eql(u8, mod.string, "hyper")) mods.hyper = true;
        if (std.mem.eql(u8, mod.string, "meta")) mods.meta = true;
        if (std.mem.eql(u8, mod.string, "caps_lock")) mods.caps_lock = true;
        if (std.mem.eql(u8, mod.string, "num_lock")) mods.num_lock = true;
    }

    binding.mods = mods;
    return binding;
}

fn parseRGB(val: std.json.Value, allocator: std.mem.Allocator) ?[3]u8 {
    switch (val) {
        .string => |str| {
            var hex = str;
            if (hex.len == 0) return null;
            if (std.mem.startsWith(u8, hex, "#")) hex = hex[1..];
            if (std.mem.startsWith(u8, hex, "0x") or std.mem.startsWith(u8, hex, "0X")) hex = hex[2..];
            if (hex.len != 6) return null;

            const rgb_int = std.fmt.parseInt(u32, hex, 16) catch return null;
            const r = @as(u8, @intCast((rgb_int >> 16) & 0xFF));
            const g = @as(u8, @intCast((rgb_int >> 8) & 0xFF));
            const b = @as(u8, @intCast(rgb_int & 0xFF));
            return .{ r, g, b };
        },
        .object => |obj| {
            const rgb_val = obj.get("rgb") orelse return null;
            const rgb = std.json.innerParseFromValue([3]u8, allocator, rgb_val, .{}) catch return null;
            return rgb;
        },
        else => return null,
    }
}
