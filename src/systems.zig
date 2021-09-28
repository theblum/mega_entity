const std = @import("std");
const log = std.log.scoped(.systems);

const State = @import("state.zig").State;
const SystemManager = @import("engine").SystemManager(State);

const bouncyBallsFns = @import("systems/bouncy_balls.zig");
const randomDragFns = @import("systems/random_drag.zig");
const playerMoveFns = @import("systems/player_move.zig");

const ballSpawner = @import("systems/ball_spawner.zig");
const physics = @import("systems/physics.zig");
const render = @import("systems/render.zig");

pub const bouncyBalls = SystemManager.Item{
    .initFn = bouncyBallsFns.init,
    .deinitFn = bouncyBallsFns.deinit,
    .tickFns = &.{ ballSpawner.tick, physics.tick, render.tick },
};

pub const playerMove = SystemManager.Item{
    .initFn = playerMoveFns.init,
    .deinitFn = playerMoveFns.deinit,
    .tickFns = &.{ playerMoveFns.tick, render.tick },
};

pub const randomDrag = SystemManager.Item{
    .initFn = randomDragFns.init,
    .deinitFn = randomDragFns.deinit,
    .tickFns = &.{ ballSpawner.tick, physics.tick, render.tick },
};

fn init(_: *State) bool {
    return false;
}

fn deinit(_: *State) void {
    return;
}
