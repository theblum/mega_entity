const std = @import("std");
const log = std.log.scoped(.state);

const GameStates = @import("game_states.zig").GameStates;

pub const State = struct {
    deltaTime: f32,
};
