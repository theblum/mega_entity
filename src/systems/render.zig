const std = @import("std");
const log = std.log.scoped(.renderSystem);
const c = @import("../c.zig");
const m = @import("zlm");

const EntityManager = @import("../entity_manager.zig").EntityManager;

pub fn tick(manager: *EntityManager, _: f32) void {
    for (manager.entities) |*item| {
        if (item.entity) |*entity| {
            if (!entity.flagIsSet(.isRenderable))
                continue;

            const color = .{
                .r = @floatToInt(u8, entity.color.x * 255.0),
                .g = @floatToInt(u8, entity.color.y * 255.0),
                .b = @floatToInt(u8, entity.color.z * 255.0),
                .a = @floatToInt(u8, entity.color.w * 255.0),
            };

            const radius = entity.mass * 16.0;

            c.DrawCircle(@floatToInt(i32, entity.position.x), @floatToInt(i32, entity.position.y), radius, color);
        }
    }
}
