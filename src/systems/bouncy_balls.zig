const std = @import("std");
const log = std.log.scoped(.bouncyBallsSystem);

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const State = @import("../state.zig").State;

pub fn start(_: *State) bool {
    return true;
}

var ballSpawnerHandles = &@import("ball_spawner.zig").handles;
var ballSpawnerHandlesCount = &@import("ball_spawner.zig").handlesCount;

pub fn end(_: *State) void {
    for (ballSpawnerHandles[0..ballSpawnerHandlesCount.*]) |handle|
        gbls.entityManager.deleteEntity(handle);

    ballSpawnerHandlesCount.* = 0;
}
