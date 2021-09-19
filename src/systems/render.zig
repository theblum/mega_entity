const std = @import("std");
const log = std.log.scoped(.renderSystem);
const c = @import("../c.zig");

const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

pub const flags = [_]EntityFlags{.isRenderable};

pub fn tick(entity: *Entity, state: *State) void {
    const color = .{
        .r = @floatToInt(u8, entity.color.x * 255.0),
        .g = @floatToInt(u8, entity.color.y * 255.0),
        .b = @floatToInt(u8, entity.color.z * 255.0),
        .a = @floatToInt(u8, entity.color.w * 255.0),
    };

    const radius = entity.mass * 16.0;

    c.sfCircleShape_setPosition(state.circle, .{ .x = entity.position.x, .y = entity.position.y });
    c.sfCircleShape_setRadius(state.circle, radius);
    c.sfCircleShape_setFillColor(state.circle, color);
    c.sfCircleShape_setOutlineColor(state.circle, c.sfColor_fromInteger(0x222222ff));
    c.sfCircleShape_setOutlineThickness(state.circle, 1.0);
    c.sfRenderWindow_drawCircleShape(state.window, state.circle, null);
}
