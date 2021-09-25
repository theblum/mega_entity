const std = @import("std");
const log = std.log.scoped(.physicsSystem);
const m = @import("zlm");

const globals = &@import("../globals.zig").globals;

const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

pub const flags = [_]EntityFlags{.hasPhysics};

pub fn tick(state: *State) void {
    globals.profiler.start("Physics System");

    var iterator = globals.entityManager.iterator();
    while (iterator.next(&flags)) |item| {
        var entity = &item.entity.?;

        const gravity = m.vec2(0.0, 500.0);
        const wind = m.vec2(10.0, 0.0);
        applyForce(entity, gravity.scale(entity.mass));
        applyForce(entity, wind);

        var drag = entity.velocity.normalize().scale(-1.0);
        const dragCoef = 0.05;
        drag = drag.scale(entity.velocity.length2() * dragCoef);
        applyForce(entity, drag);

        if (globals.window.size.y - (entity.position.y + entity.radius) < 1.0) {
            var friction = entity.velocity.normalize().scale(-1.0);
            const frictionCoef = 50.0;
            friction = friction.scale(frictionCoef);
            applyForce(entity, friction);
        }

        entity.velocity = entity.velocity.add(entity.acceleration.scale(state.dt));
        entity.position = entity.position.add(entity.velocity.scale(state.dt));
        entity.acceleration = entity.acceleration.scale(0.0);

        if (entity.position.x > globals.window.size.x - entity.radius) {
            entity.position.x = globals.window.size.x - entity.radius;
            entity.velocity.x *= -1.0;
        } else if (entity.position.x < 0 + entity.radius) {
            entity.position.x = entity.radius;
            entity.velocity.x *= -1.0;
        }

        if (entity.position.y > globals.window.size.y - entity.radius) {
            entity.position.y = globals.window.size.y - entity.radius;
            entity.velocity.y *= -1.0;
        }
    }

    globals.profiler.end();
}

fn applyForce(entity: *Entity, force: m.Vec2) void {
    entity.acceleration = entity.acceleration.add(force.scale(1.0 / entity.mass));
}
