const vaxis = @import("vaxis");

pub const CachedImage = struct { image: vaxis.Image };
pub const Key = struct {
    colorize: bool,
    page: u16,
    width_mode: bool,
    zoom: u32,
    x_offset: i32,
    y_offset: i32,
};
