const Self = @This();
const std = @import("std");
const types = @import("./types.zig");
const Config = @import("../config/config.zig");
const Utilities = @import("../utilities/utilities.zig");

const c = @cImport({
    @cInclude("fitz-z.h");
    @cInclude("mupdf/fitz.h");
    @cInclude("mupdf/pdf.h");
});

allocator: std.mem.Allocator,
doc: [*c]c.fz_document,
ctx: [*c]c.fz_context,
default_zoom: f32,
active_zoom: f32,
total_pages: u16,
path: []const u8,
width_mode: bool,
config: *Config,
y_offset: f32,
x_offset: f32,
y_center: f32,
x_center: f32,

pub fn init(
    allocator: std.mem.Allocator,
    path: []const u8,
    config: *Config,
) !Self {
    const ctx = c.fz_new_context(null, null, c.FZ_STORE_UNLIMITED) orelse {
        std.debug.print("Failed to create mupdf context\n", .{});
        return types.DocumentError.FailedToCreateContext;
    };
    errdefer c.fz_drop_context(ctx);

    c.fz_register_document_handlers(ctx);
    c.fz_set_error_callback(ctx, null, null);
    c.fz_set_warning_callback(ctx, null, null);

    const doc = c.fz_open_document_z(ctx, path.ptr) orelse {
        const err_msg = c.fz_caught_message(ctx);
        std.debug.print("Failed to open document: {s}\n", .{err_msg});
        return types.DocumentError.FailedToOpenDocument;
    };
    errdefer c.fz_drop_document(ctx, doc);

    const total_pages = @as(u16, @intCast(c.fz_count_pages(ctx, doc)));

    return .{
        .allocator = allocator,
        .ctx = ctx,
        .doc = doc,
        .total_pages = total_pages,
        .path = path,
        .active_zoom = 0,
        .default_zoom = 0,
        .width_mode = false,
        .y_offset = 0,
        .x_offset = 0,
        .y_center = 0,
        .x_center = 0,
        .config = config,
    };
}

pub fn deinit(self: *Self) void {
    c.fz_drop_document(self.ctx, self.doc);
    c.fz_drop_context(self.ctx);
}

fn calculateZoomLevel(self: *Self, window_width: u32, window_height: u32, bound: c.fz_rect) void {
    var scale: f32 = 0;
    if (self.width_mode) {
        scale = @as(f32, @floatFromInt(window_width)) / bound.x1;
    } else {
        scale = @min(
            @as(f32, @floatFromInt(window_width)) / bound.x1,
            @as(f32, @floatFromInt(window_height)) / bound.y1,
        );
    }

    // initial zoom
    if (self.default_zoom == 0) {
        self.default_zoom = scale * self.config.general.size;
    }

    if (self.active_zoom == 0) {
        self.active_zoom = self.default_zoom;
    }

    self.active_zoom = @max(self.active_zoom, self.config.general.zoom_min);
}

fn calculateXY(self: *Self, view_width: f32, view_height: f32, bound: c.fz_rect) void {
    // translation to center view
    self.x_center = (bound.x1 - view_width / self.active_zoom) / 2;
    self.y_center = (bound.y1 - view_height / self.active_zoom) / 2;

    if (self.x_offset == 0 and self.y_offset == 0 and self.width_mode) {
        self.y_offset = self.y_center;
    }

    // don't scroll off page
    self.x_offset = c.fz_clamp(self.x_offset, -self.x_center, self.x_center);
    self.y_offset = c.fz_clamp(self.y_offset, -self.y_center, self.y_center);
}

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

pub fn getWidthMode(self: *Self) bool {
    return self.width_mode;
}

pub fn toggleWidthMode(self: *Self) void {
    self.default_zoom = 0;
    self.active_zoom = 0;
    self.width_mode = !self.width_mode;
}

pub fn toggleColor(self: *Self) void {
    self.config.general.colorize = !self.config.general.colorize;
}
