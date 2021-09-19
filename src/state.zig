const std = @import("std");
const log = std.log.scoped(.state);

const EntityManager = @import("entity_manager.zig").EntityManager;

pub const State = struct {
    entityManager: EntityManager,
    dt: f32,
};
