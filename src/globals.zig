const std = @import("std");
const log = std.log.scoped(.globals);

const State = @import("state.zig").State;
const GameStates = @import("game_states.zig").GameStates;
const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;

const Window = @import("engine").Window;
const Renderer = @import("engine").Renderer;
const EntityManager = @import("engine").EntityManager(Entity, EntityFlags);

const Profiler = @import("profiler.zig").Profiler;

const Globals = struct {
    rand: *std.rand.Random,

    entityManager: EntityManager,
    gameStates: GameStates.Array,

    window: Window,
    renderer: Renderer,

    profiler: Profiler,
};

pub var globals: Globals = undefined;
