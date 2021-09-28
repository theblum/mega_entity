const std = @import("std");
const log = std.log.scoped(.physicsSystem);
const m = @import("zlm");

const globals = &@import("../globals.zig").globals;

const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

const flags = [_]EntityFlags{.hasPhysics};

pub fn tick(state: *State) void {
    globals.profiler.start("Physics System");

    var iterator = globals.entityManager.iterator();
    while (iterator.next(&flags)) |item| {
        var entity = &item.entity.?;

        const gravity = m.vec2(0.0, 500.0);
        const wind = m.vec2(10.0, 0.0);
        applyForce(entity, gravity.scale(entity.mass));
        applyForce(entity, wind);

        var dragIter = globals.entityManager.iterator();
        while (dragIter.next(&.{.hasDrag})) |dragItem| {
            var dragEntity = &dragItem.entity.?;
            if (circlesCollide(entity, dragEntity)) {
                var drag = entity.velocity.normalize().scale(-1.0);
                drag = drag.scale(entity.velocity.length2() * dragEntity.drag);
                applyForce(entity, drag);
            }
        }

        if (globals.window.size.y - (entity.position.y + entity.radius) < 1.0) {
            var friction = entity.velocity.normalize().scale(-1.0);
            const frictionCoef = 50.0;
            friction = friction.scale(frictionCoef);
            applyForce(entity, friction);
        }

        entity.velocity = entity.velocity.add(entity.acceleration.scale(state.deltaTime));
        entity.position = entity.position.add(entity.velocity.scale(state.deltaTime));
        entity.acceleration = entity.acceleration.scale(0.0);

        if (entity.position.x > globals.window.size.x - entity.radius) {
            entity.position.x = globals.window.size.x - entity.radius;
            entity.velocity.x *= -entity.bounce;
        } else if (entity.position.x < 0 + entity.radius) {
            entity.position.x = entity.radius;
            entity.velocity.x *= -entity.bounce;
        }

        if (entity.position.y > globals.window.size.y - entity.radius) {
            entity.position.y = globals.window.size.y - entity.radius;
            entity.velocity.y *= -entity.bounce;
        }
    }

    globals.profiler.end();
}

fn applyForce(entity: *Entity, force: m.Vec2) void {
    entity.acceleration = entity.acceleration.add(force.scale(1.0 / entity.mass));
}

fn circlesCollide(entity1: *Entity, entity2: *Entity) bool {
    const distance = entity1.position.sub(entity2.position).length();
    return distance < entity1.radius + entity2.radius;
}
