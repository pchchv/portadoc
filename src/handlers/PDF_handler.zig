const Self = @This();
const std = @import("std");
const types = @import("./types.zig");
const Config = @import("../config/config.zig");
const Utilities = @import("../utilities/utilities.zig");

active_zoom: f32,
default_zoom: f32,
y_offset: f32,
x_offset: f32,
config: *Config,

pub fn zoomIn(self: *Self) void {
    self.active_zoom *= self.config.general.zoom_step;
}

pub fn zoomOut(self: *Self) void {
    self.active_zoom /= self.config.general.zoom_step;
}

pub fn setZoom(self: *Self, percent: f32) void {
    var dpi = self.config.general.dpi;
    if (self.config.general.detect_dpi) dpi = Utilities.getDPI() orelse dpi;

    self.active_zoom = @max(percent * dpi / 7200.0, self.config.general.zoom_min);
}

pub fn resetDefaultZoom(self: *Self) void {
    self.default_zoom = 0;
}

pub fn resetZoomAndScroll(self: *Self) void {
    self.active_zoom = self.default_zoom;
    self.y_offset = 0;
    self.x_offset = 0;
}

pub fn scroll(self: *Self, direction: types.ScrollDirection) void {
    const step = self.config.general.scroll_step / self.active_zoom;
    switch (direction) {
        .Up => {
            const translation = self.y_offset + step;
            if (self.y_offset < translation) {
                self.y_offset = translation;
            } else {
                self.y_offset = std.math.nextAfter(f32, self.y_offset, std.math.inf(f32));
            }
        },
        .Down => {
            const translation = self.y_offset - step;
            if (self.y_offset > translation) {
                self.y_offset = translation;
            } else {
                self.y_offset = std.math.nextAfter(f32, self.y_offset, -std.math.inf(f32));
            }
        },
        .Left => {
            const translation = self.x_offset + step;
            if (self.x_offset < translation) {
                self.x_offset = translation;
            } else {
                self.x_offset = std.math.nextAfter(f32, self.x_offset, std.math.inf(f32));
            }
        },
        .Right => {
            const translation = self.x_offset - step;
            if (self.x_offset > translation) {
                self.x_offset = translation;
            } else {
                self.x_offset = std.math.nextAfter(f32, self.x_offset, -std.math.inf(f32));
            }
        },
    }
}

pub fn offsetScroll(self: *Self, dx: f32, dy: f32) void {
    self.x_offset -= dx;
    self.y_offset += dy;
}
