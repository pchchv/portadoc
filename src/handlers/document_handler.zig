const Self = @This();

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
