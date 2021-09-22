const std = @import("std");
const log = std.log.scoped(.renderSystem);
const m = @import("zlm");

const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

pub const flags = [_]EntityFlags{.isRenderable};

pub fn tick(state: *State) void {
    var iterator = state.entityManager.iterator();
    while (iterator.next(&flags)) |item| {
        var entity = item.entity.?;

        state.renderer.drawCircle(entity.position, entity.radius, .{
            .color = entity.color,
            .outlineColor = m.vec4(0.1, 0.1, 0.1, 1.0),
        });
    }
}
