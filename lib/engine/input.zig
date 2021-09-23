const std = @import("std");
const log = std.log.scoped(.input);
const c = @import("c.zig");
const m = @import("zlm");

const Window = @import("window.zig").Window;

pub const Input = struct {
    const Self = @This();

    mouseButtons: [MouseButtons.len]MouseItem = .{MouseItem{}} ** MouseButtons.len,
    window: *Window,

    const MouseButtons = enum {
        const len = @typeInfo(@This()).Enum.fields.len;

        left,
        right,
        middle,
    };

    const MouseItem = struct {
        isDown: bool = false,
        wasDown: bool = false,
    };

    pub fn init(window: *Window) Self {
        return .{ .window = window };
    }

    pub fn getMouseButton(self: Self, button: MouseButtons) MouseItem {
        return self.mouseButtons[@enumToInt(button)];
    }

    pub fn setMouseButton(self: *Self, button: MouseButtons, pressed: bool) void {
        self.mouseButtons[@enumToInt(button)].isDown = pressed;
    }

    pub fn getMousePosition(self: Self) m.Vec2 {
        const position = c.sfMouse_getPositionRenderWindow(self.window.handle);
        const windowSize = self.window.getActualSize();
        const adjustedPosition = .{
            .x = @intToFloat(f32, position.x) * self.window.width / windowSize.x,
            .y = @intToFloat(f32, position.y) * self.window.height / windowSize.y,
        };

        return adjustedPosition;
    }
};
