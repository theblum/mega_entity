const std = @import("std");
const log = std.log.scoped(.bouncyBallsSystem);

const State = @import("../state.zig").State;

pub fn start(_: *State) bool {
    return false;
}

pub fn end(_: *State) void {
    return;
}
