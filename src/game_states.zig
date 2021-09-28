const std = @import("std");
const log = std.log.scoped(.gameStates);

const State = @import("state.zig").State;
const SystemManager = @import("engine").SystemManager(State);

pub const GameStates = enum {
    bouncyBalls,
    randomDrag,
    playerMove,

    pub const Value = struct {
        systemManager: SystemManager,
    };

    pub const Array = std.EnumArray(GameStates, GameStates.Value);
};
