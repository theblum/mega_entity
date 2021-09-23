const std = @import("std");
const log = std.log.scoped(.platform);
const c = @import("c.zig");
const m = @import("zlm");

const globals = &@import("globals.zig").globals;

pub const Window = struct {
    const Self = @This();

    handle: *c.sfRenderWindow,

    // @Note: These store the size of the game window, not the actual window size (they may be different if the
    // window has been resized). You can get the actual window size by calling `getActualSize()`. Storing these as
    // f32s makes calculations easier, but should we instead store as u32s and cast to f32s whenever needed?
    width: f32,
    height: f32,

    pub fn init(programName: [:0]const u8, width: u32, height: u32, targetFPS: u32) !Self {
        var result: Window = undefined;
        result.width = @intToFloat(f32, width);
        result.height = @intToFloat(f32, height);

        // @Note: These are all just the default settings except for `antialiasingLevel`.
        // Also, as per the documentation: All these settings with the exception of the compatibility
        // flag and anti-aliasing level have no impact on the regular SFML rendering (graphics module),
        // so you may need to use this structure only if you're using SFML as a windowing system for
        // custom OpenGL rendering.
        const settings = .{
            .depthBits = 0,
            .stencilBits = 0,
            .antialiasingLevel = 8,
            .majorVersion = 1,
            .minorVersion = 1,
            .attributeFlags = c.sfContextDefault,
            .sRgbCapable = c.sfFalse,
        };

        result.handle = c.sfRenderWindow_create(
            .{ .width = width, .height = height, .bitsPerPixel = 32 },
            programName,
            c.sfDefaultStyle,
            &settings,
        ) orelse return error.WindowCreationFailed;

        c.sfRenderWindow_setVerticalSyncEnabled(result.handle, c.sfFalse);
        if (targetFPS > 0)
            c.sfRenderWindow_setFramerateLimit(result.handle, targetFPS);

        return result;
    }

    pub fn deinit(self: Self) void {
        c.sfRenderWindow_destroy(self.handle);
    }

    pub fn isOpen(self: Self) bool {
        return c.sfRenderWindow_isOpen(self.handle) == c.sfTrue;
    }

    pub fn getActualSize(self: Self) m.Vec2 {
        var size = c.sfRenderWindow_getSize(self.handle);
        return .{ .x = @intToFloat(f32, size.x), .y = @intToFloat(f32, size.y) };
    }

    pub fn pollEvents(self: Self) void {
        for (globals.input.mouseButtons) |*button|
            button.wasDown = button.isDown;

        var event: c.sfEvent = undefined;
        while (c.sfRenderWindow_pollEvent(self.handle, &event) == c.sfTrue) {
            switch (event.type) {
                c.sfEvtClosed => c.sfRenderWindow_close(self.handle),

                c.sfEvtKeyPressed => {
                    if (event.key.code == c.sfKeyEscape)
                        c.sfRenderWindow_close(self.handle);
                },

                c.sfEvtMouseButtonPressed, c.sfEvtMouseButtonReleased => {
                    const pressed = if (event.type == c.sfEvtMouseButtonPressed) true else false;

                    switch (event.mouseButton.button) {
                        c.sfMouseLeft => globals.input.setMouseButton(.left, pressed),
                        c.sfMouseRight => globals.input.setMouseButton(.right, pressed),
                        c.sfMouseMiddle => globals.input.setMouseButton(.middle, pressed),
                        else => {},
                    }
                },

                else => {},
            }
        }
    }
};

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

pub const Input = struct {
    const Self = @This();

    mouseButtons: [MouseButtons.len]MouseItem = .{MouseItem{}} ** MouseButtons.len,

    pub fn init() Self {
        return .{};
    }

    pub fn getMouseButton(self: Self, button: MouseButtons) MouseItem {
        return self.mouseButtons[@enumToInt(button)];
    }

    pub fn setMouseButton(self: *Self, button: MouseButtons, pressed: bool) void {
        self.mouseButtons[@enumToInt(button)].isDown = pressed;
    }

    pub fn getMousePosition(self: Self) m.Vec2 {
        _ = self;
        const position = c.sfMouse_getPositionRenderWindow(globals.window.handle);
        const windowSize = globals.window.getActualSize();
        const adjustedPosition = .{
            .x = @intToFloat(f32, position.x) * globals.window.width / windowSize.x,
            .y = @intToFloat(f32, position.y) * globals.window.height / windowSize.y,
        };

        return adjustedPosition;
    }
};

pub const Clock = struct {
    const Self = @This();

    handle: *c.sfClock,

    pub fn init() !Self {
        var result = .{
            .handle = c.sfClock_create() orelse return error.LoadingError,
        };

        return result;
    }

    pub fn deinit(self: Self) void {
        c.sfClock_destroy(self.handle);
    }

    pub fn getSecondsAndRestart(self: Self) f32 {
        return c.sfTime_asSeconds(c.sfClock_restart(self.handle));
    }
};
