const std = @import("std");
const log = std.log.scoped(.entity);
const m = @import("zlm");

pub const Entity = struct {
    flags: struct {
        isAlive: bool = false,
    } = .{},

    position: m.Vec2 = undefined,
    velocity: m.Vec2 = undefined,
    acceleration: m.Vec2 = undefined,
};
