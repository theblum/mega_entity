const std = @import("std");
const log = std.log.scoped(.globals);

const State = @import("state.zig").State;
const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const GameStates = @import("game_states.zig").GameStates;

const Window = @import("engine").Window;
const Renderer = @import("engine").Renderer;
const EntityManager = @import("engine").EntityManager(Entity, EntityFlags);
const GameStateManager = @import("engine").GameStateManager(GameStates, State);

const Profiler = @import("profiler.zig").Profiler;

const Globals = struct {
    rand: *std.rand.Random,

    entityManager: EntityManager,
    gameStateManager: GameStateManager,

    window: Window,
    renderer: Renderer,

    profiler: Profiler,
};

pub var globals: Globals = undefined;
