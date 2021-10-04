const std = @import("std");
const log = std.log.scoped(.systems);

const globals = @import("globals.zig");

const State = @import("state.zig").State;
const SystemManager = globals.engine.SystemManager;

const bouncyBallsFns = @import("systems/bouncy_balls.zig");
const randomDragFns = @import("systems/random_drag.zig");
const playerMoveFns = @import("systems/player_move.zig");
const gravitationalPullFns = @import("systems/gravitational_pull.zig");

const ballSpawner = @import("systems/ball_spawner.zig");
const physics = @import("systems/physics.zig");
const render = @import("systems/render.zig");
const gameStateChanger = @import("systems/game_state_changer.zig");

pub const bouncyBalls = SystemManager.Item{
    .startFn = bouncyBallsFns.start,
    .endFn = bouncyBallsFns.end,
    .tickFns = &.{ gameStateChanger.tick, ballSpawner.tick, physics.tick, render.tick },
};

pub const randomDrag = SystemManager.Item{
    .startFn = randomDragFns.start,
    .endFn = randomDragFns.end,
    .tickFns = &.{ gameStateChanger.tick, ballSpawner.tick, physics.tick, render.tick },
};

pub const playerMove = SystemManager.Item{
    .startFn = playerMoveFns.start,
    .endFn = playerMoveFns.end,
    .tickFns = &.{ gameStateChanger.tick, playerMoveFns.tick, render.tick },
};

pub const gravitationalPull = SystemManager.Item{
    .startFn = gravitationalPullFns.start,
    .endFn = gravitationalPullFns.end,
    .tickFns = &.{ gameStateChanger.tick, gravitationalPullFns.tick, render.tick },
};
