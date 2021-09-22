const std = @import("std");
const log = std.log.scoped(.state);

const platform = @import("platform.zig");
const Window = platform.Window;
const Input = platform.Input;
const Renderer = @import("renderer.zig").Renderer;
const EntityManager = @import("entity_manager.zig").EntityManager;

pub const State = struct {
    entityManager: EntityManager,
    dt: f32,

    rand: *std.rand.Random,

    window: Window,
    input: Input,
    renderer: Renderer,
};
