const Self = @This();
const types = @import("./types.zig");

pub fn getWidthMode(self: *Self) bool {
    return self.pdf_handler.getWidthMode();
}

pub fn getCurrentPageNumber(self: *Self) u16 {
    return self.current_page_number;
}

pub fn getPath(self: *Self) []const u8 {
    return self.pdf_handler.path;
}

pub fn getTotalPages(self: *Self) u16 {
    return self.pdf_handler.total_pages;
}

pub fn getActiveZoom(self: *Self) f32 {
    return self.pdf_handler.active_zoom;
}

pub fn getXOffset(self: *Self) f32 {
    return self.pdf_handler.x_offset;
}

pub fn getYOffset(self: *Self) f32 {
    return self.pdf_handler.y_offset;
}

pub fn zoomIn(self: *Self) void {
    self.pdf_handler.zoomIn();
}

pub fn zoomOut(self: *Self) void {
    self.pdf_handler.zoomOut();
}

pub fn setZoom(self: *Self, percent: f32) void {
    self.pdf_handler.setZoom(percent);
}

pub fn resetDefaultZoom(self: *Self) void {
    self.pdf_handler.resetDefaultZoom();
}

pub fn resetZoomAndScroll(self: *Self) void {
    self.pdf_handler.resetZoomAndScroll();
}

pub fn scroll(self: *Self, direction: types.ScrollDirection) void {
    self.pdf_handler.scroll(direction);
}

pub fn offsetScroll(self: *Self, dx: f32, dy: f32) void {
    self.pdf_handler.offsetScroll(dx, dy);
}
