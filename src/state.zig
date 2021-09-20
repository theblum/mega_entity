const std = @import("std");
const log = std.log.scoped(.state);
const c = @import("c.zig");

const platform = @import("platform.zig");
const Window = platform.Window;
const Renderer = @import("renderer.zig").Renderer;
const EntityManager = @import("entity_manager.zig").EntityManager;

pub const State = struct {
    entityManager: EntityManager,
    dt: f32,

    window: Window,
    renderer: Renderer,
};
