const std = @import("std");
const log = std.log.scoped(.globals);

const platform = @import("platform.zig");
const Window = platform.Window;
const Input = platform.Input;
const Renderer = @import("renderer.zig").Renderer;
const EntityManager = @import("entity_manager.zig").EntityManager;
const SystemManager = @import("system_manager.zig").SystemManager;
const Profiler = @import("profiler.zig").Profiler;

const Globals = struct {
    rand: *std.rand.Random,

    entityManager: EntityManager,
    systemManager: SystemManager,

    window: Window,
    input: Input,
    renderer: Renderer,

    profiler: Profiler,
};

pub var globals: Globals = undefined;
