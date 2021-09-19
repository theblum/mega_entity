const std = @import("std");
const log = std.log.scoped(.physicsSystem);
const m = @import("zlm");

const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

const gravity = m.vec2(0.0, 9.81 * 9.81);
const wind = m.vec2(10.0, 0.0);

pub const flags = [_]EntityFlags{.hasPhysics};

pub fn tick(entity: *Entity, state: *State) void {
    entity.acceleration = entity.acceleration.add(gravity);
    entity.acceleration = entity.acceleration.add(wind.scale(1.0 / entity.mass));

    entity.velocity = entity.velocity.add(entity.acceleration.scale(state.dt));
    entity.position = entity.position.add(entity.velocity.scale(state.dt));
    entity.acceleration = entity.acceleration.scale(0.0);

    if (entity.position.x > @intToFloat(f32, state.renderWidth)) {
        entity.position.x = @intToFloat(f32, state.renderWidth);
        entity.velocity.x *= -1.0;
    } else if (entity.position.x < 0) {
        entity.position.x = 0;
        entity.velocity.x *= -1.0;
    }

    if (entity.position.y > @intToFloat(f32, state.renderHeight)) {
        entity.position.y = @intToFloat(f32, state.renderHeight);
        entity.velocity.y *= -1;
    }
}
