const std = @import("std");
const log = std.log.scoped(.systems);

const State = @import("state.zig").State;

const ballSpawner = @import("systems/ball_spawner.zig");
const dragSpawner = @import("systems/drag_spawner.zig");
const physics = @import("systems/physics.zig");
const player = @import("systems/player.zig");
const render = @import("systems/render.zig");

pub const SystemItem = struct {
    tickFn: fn (*State) void,
};

pub const list = [_]SystemItem{
    .{ .tickFn = ballSpawner.tick },
    .{ .tickFn = dragSpawner.tick },
    .{ .tickFn = physics.tick },
    .{ .tickFn = player.tick },
    .{ .tickFn = render.tick },
};
