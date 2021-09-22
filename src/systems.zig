const std = @import("std");
const log = std.log.scoped(.systems);

const State = @import("state.zig").State;

const spawner = @import("systems/spawner.zig");
const physics = @import("systems/physics.zig");
const render = @import("systems/render.zig");

pub const SystemItem = struct {
    tickFn: fn (*State) void,
};

pub const systemList = [_]SystemItem{
    .{ .tickFn = spawner.tick },
    .{ .tickFn = physics.tick },
    .{ .tickFn = render.tick },
};
