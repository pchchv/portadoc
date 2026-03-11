const Self = @This();
const std = @import("std");

pub fn addToHistory(self: *Self, cmd: []const u8) void {
    if (self.config.general.history <= 0) return;
    for (self.items.items, 0..) |existing_cmd, i| {
        if (std.mem.eql(u8, existing_cmd, cmd)) {
            self.allocator.free(self.items.orderedRemove(i));
            break;
        }
    }

    const cmd_copy = self.allocator.dupe(u8, cmd) catch return;
    self.items.append(self.allocator, cmd_copy) catch {
        self.allocator.free(cmd_copy);
        return;
    };

    const max: usize = self.config.general.history;
    while (self.items.items.len > max) {
        const removed = self.items.orderedRemove(0);
        self.allocator.free(removed);
    }

    self.index = -1;
}
