const std = @import("std");
const log = std.log.scoped(.renderSystem);
const c = @import("../c.zig");

const Entity = @import("../entity.zig").Entity;
const State = @import("../state.zig").State;

pub fn tick(entity: *Entity, _: *State) void {
    if (!entity.flagIsSet(.isRenderable))
        return;

    const color = .{
        .r = @floatToInt(u8, entity.color.x * 255.0),
        .g = @floatToInt(u8, entity.color.y * 255.0),
        .b = @floatToInt(u8, entity.color.z * 255.0),
        .a = @floatToInt(u8, entity.color.w * 255.0),
    };

    const radius = entity.mass * 16.0;

    c.DrawCircle(@floatToInt(i32, entity.position.x), @floatToInt(i32, entity.position.y), radius, color);
}
