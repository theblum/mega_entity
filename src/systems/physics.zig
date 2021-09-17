const std = @import("std");
const log = std.log.scoped(.physicsSystem);
const m = @import("zlm");
const root = @import("root");

const EntityManager = @import("../entity_manager.zig").EntityManager;

const gravity = m.vec2(0.0, 9.81 * 9.81);
const wind = m.vec2(10.0, 0.0);

pub fn tick(manager: *EntityManager, dt: f32) void {
    for (manager.entities) |*item| {
        if (item.entity) |*entity| {
            if (!entity.flagIsSet(.hasPhysics))
                continue;

            entity.acceleration = entity.acceleration.add(gravity);
            entity.acceleration = entity.acceleration.add(wind.scale(1.0 / entity.mass));

            entity.velocity = entity.velocity.add(entity.acceleration.scale(dt));
            entity.position = entity.position.add(entity.velocity.scale(dt));
            entity.acceleration = entity.acceleration.scale(0.0);

            if (entity.position.x > root.renderWidth) {
                entity.position.x = root.renderWidth;
                entity.velocity.x *= -1.0;
            } else if (entity.position.x < 0) {
                entity.position.x = 0;
                entity.velocity.x *= -1.0;
            }

            if (entity.position.y > root.renderHeight) {
                entity.position.y = root.renderHeight;
                entity.velocity.y *= -1;
            }
        }
    }
}
