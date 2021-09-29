const std = @import("std");
const log = std.log.scoped(.renderSystem);
const m = @import("zlm");

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

const flags = [_]EntityFlags{.isRenderable};

pub fn tick(_: *State) void {
    gbls.profiler.start("Render System");

    var iterator = gbls.entityManager.iterator();
    while (iterator.next(&flags)) |item| {
        var entity = item.entity.?;

        switch (entity.renderType) {
            .circle => gbls.renderer.drawCircle(entity.position, entity.radius, .{
                .color = entity.color,
                .outlineColor = m.vec4(0.1, 0.1, 0.1, 1.0),
                .rotation = entity.rotation,
            }),

            .rectangle => gbls.renderer.drawRectangle(entity.position, entity.size, .{
                .color = entity.color,
                .outlineColor = m.vec4(0.1, 0.1, 0.1, 1.0),
                .rotation = entity.rotation,
            }),

            else => log.err("Unknown render type: {s}", .{entity.renderType}),
        }
    }

    gbls.profiler.end();
}
