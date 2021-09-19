const std = @import("std");
const log = std.log.scoped(.state);
const c = @import("c.zig");

const EntityManager = @import("entity_manager.zig").EntityManager;

pub const State = struct {
    entityManager: EntityManager,
    dt: f32,

    renderWidth: u32,
    renderHeight: u32,

    window: *c.sfRenderWindow,
    circle: *c.sfCircleShape,
    font: *c.sfFont,
};
