const std = @import("std");
const log = std.log.scoped(.physicsSystem);
const m = @import("zlm");

const Entity = @import("../entity.zig").Entity;
const EntityHandle = @import("../entity_manager.zig").EntityHandle;
const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

const gravity = m.vec2(0.0, 9.81 * 9.81);
const wind = m.vec2(10.0, 0.0);

pub const flags = [_]EntityFlags{.hasPhysics};

pub fn tick(entity: *Entity, handle: EntityHandle, state: *State) void {
    _ = handle;

    entity.acceleration = entity.acceleration.add(gravity);
    entity.acceleration = entity.acceleration.add(wind.scale(1.0 / entity.mass));

    entity.velocity = entity.velocity.add(entity.acceleration.scale(state.dt));
    entity.position = entity.position.add(entity.velocity.scale(state.dt));
    entity.acceleration = entity.acceleration.scale(0.0);

    if (entity.position.x > state.window.width - entity.radius) {
        entity.position.x = state.window.width - entity.radius;
        entity.velocity.x *= -1.0;
    } else if (entity.position.x < 0 + entity.radius) {
        entity.position.x = entity.radius;
        entity.velocity.x *= -1.0;
    }

    if (entity.position.y > state.window.height - entity.radius) {
        entity.position.y = state.window.height - entity.radius;
        entity.velocity.y *= -1;
    }
}
