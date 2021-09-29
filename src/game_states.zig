const std = @import("std");
const log = std.log.scoped(.gameStates);

pub const GameStates = enum {
    pub const len = @typeInfo(@This()).Enum.fields.len;

    bouncyBalls,
    randomDrag,
    playerMove,
};
