const std = @import("std");
const log = std.log.scoped(.renderSystem);
const m = @import("zlm");

const globals = &@import("../globals.zig").globals;

const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

const flags = [_]EntityFlags{.isRenderable};

pub fn tick(state: *State) void {
    _ = state;

    globals.profiler.start("Render System");

    var iterator = globals.entityManager.iterator();
    while (iterator.next(&flags)) |item| {
        var entity = item.entity.?;

        switch (entity.renderType) {
            .circle => globals.renderer.drawCircle(entity.position, entity.radius, .{
                .color = entity.color,
                .outlineColor = m.vec4(0.1, 0.1, 0.1, 1.0),
                .rotation = entity.rotation,
            }),

            .rectangle => globals.renderer.drawRectangle(entity.position, entity.size, .{
                .color = entity.color,
                .outlineColor = m.vec4(0.1, 0.1, 0.1, 1.0),
                .rotation = entity.rotation,
            }),

            else => log.err("Unknown render type: {s}", .{entity.renderType}),
        }
    }

    globals.profiler.end();
}
