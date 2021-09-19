const std = @import("std");
const log = std.log.scoped(.state);
const c = @import("c.zig");

const EntityManager = @import("entity_manager.zig").EntityManager;

pub const State = struct {
    window: *c.sfRenderWindow,
    entityManager: EntityManager,
    dt: f32,
    circle: *c.sfCircleShape,
    font: *c.sfFont,
};
