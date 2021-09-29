const std = @import("std");
const log = std.log.scoped(.globals);

const State = @import("state.zig").State;
const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const GameStates = @import("game_states.zig").GameStates;

const Profiler = @import("profiler.zig").Profiler;

pub const engine = struct {
    pub const Window = @import("engine").Window;
    pub const Clock = @import("engine").Clock;
    pub const Renderer = @import("engine").Renderer;
    pub const EntityManager = @import("engine").EntityManager(Entity, EntityFlags);
    pub const SystemManager = @import("engine").SystemManager(State);
    pub const GameStateManager = @import("engine").GameStateManager(GameStates, State);
};

const Globals = struct {
    rand: *std.rand.Random,

    entityManager: engine.EntityManager,
    gameStateManager: engine.GameStateManager,

    window: engine.Window,
    renderer: engine.Renderer,

    profiler: Profiler,
};

pub var gbls: Globals = undefined;
