const std = @import("std");
const log = std.log.scoped(.globals);

const State = @import("state.zig").State;
const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const SystemItem = @import("systems.zig").SystemItem;

const Window = @import("engine").Window;
const Renderer = @import("engine").Renderer;
const EntityManager = @import("engine").EntityManager(Entity, EntityFlags);
const SystemManager = @import("engine").SystemManager(SystemItem, State);

const Profiler = @import("profiler.zig").Profiler;

const Globals = struct {
    rand: *std.rand.Random,

    entityManager: EntityManager,
    systemManager: SystemManager,

    window: Window,
    renderer: Renderer,

    profiler: Profiler,
};

pub var globals: Globals = undefined;
