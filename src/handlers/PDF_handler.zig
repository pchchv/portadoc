const Self = @This();
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
