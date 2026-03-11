pub const ScrollDirection = enum { Up, Down, Left, Right };

pub const EncodedImage = struct { base64: []const u8, width: u16, height: u16 };
