const std = @import("std");
const log = std.log.scoped(.renderSystem);
const c = @import("../c.zig");
const m = @import("zlm");

const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

pub const flags = [_]EntityFlags{.isRenderable};

pub fn tick(entity: *Entity, state: *State) void {
    state.renderer.drawCircle(entity.position, entity.radius, .{
        .color = entity.color,
        .outlineColor = m.vec4(0.1, 0.1, 0.1, 1.0),
    });
}
