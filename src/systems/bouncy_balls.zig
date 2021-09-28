const std = @import("std");
const log = std.log.scoped(.bouncyBallsSystem);

const State = @import("../state.zig").State;

pub fn init(_: *State) bool {
    return false;
}

pub fn deinit(_: *State) void {
    return;
}
