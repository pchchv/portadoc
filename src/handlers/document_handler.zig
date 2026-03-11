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

pub fn toggleColor(self: *Self) void {
    self.pdf_handler.toggleColor();
}

pub fn toggleWidthMode(self: *Self) void {
    self.pdf_handler.toggleWidthMode();
}

pub fn goToPage(self: *Self, page_num: u16) bool {
    if (page_num >= 1 and page_num <= self.getTotalPages() and page_num != self.current_page_number + 1) {
        self.current_page_number = @as(u16, @intCast(page_num)) - 1;
        return true;
    }
    return false;
}

pub fn changePage(self: *Self, delta: i32) bool {
    const new_page = @as(i32, @intCast(self.current_page_number)) + delta;
    if (new_page >= 0 and new_page < self.getTotalPages()) {
        self.current_page_number = @as(u16, @intCast(new_page));
        return true;
    }
    return false;
}

pub fn renderPage(self: *Self, page_number: u16, window_width: u32, window_height: u32) !types.EncodedImage {
    return try self.pdf_handler.renderPage(page_number, window_width, window_height);
}

pub fn reloadDocument(self: *Self) !void {
    try self.pdf_handler.reloadDocument();
    if (self.current_page_number >= self.pdf_handler.total_pages) {
        self.current_page_number = self.pdf_handler.total_pages - 1;
    }
}
