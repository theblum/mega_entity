const std = @import("std");
const log = std.log.scoped(.gameStates);

pub const GameStates = enum {
    bouncyBalls,
    randomDrag,
    playerMove,
};
