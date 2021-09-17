const std = @import("std");
const log = std.log.scoped(.entity);
const m = @import("zlm");

pub const EntityFlags = enum {
    const len = @typeInfo(EntityFlags).Enum.fields.len;

    isAlive,
    isRenderable,
    hasPhysics,
};

pub const Entity = struct {
    const Self = @This();

    flags: std.StaticBitSet(EntityFlags.len) = std.StaticBitSet(EntityFlags.len).initEmpty(),

    position: m.Vec2 = undefined,
    velocity: m.Vec2 = undefined,
    acceleration: m.Vec2 = undefined,
    mass: f32 = undefined,
    color: m.Vec4 = undefined,

    pub fn flagIsSet(self: Self, flag: EntityFlags) bool {
        return self.flags.isSet(@enumToInt(flag));
    }

    pub fn setFlag(self: *Self, flag: EntityFlags) void {
        self.flags.set(@enumToInt(flag));
    }

    pub fn setFlags(self: *Self, flags: anytype) void {
        inline for (flags) |flag| {
            self.setFlag(flag);
        }
    }

    pub fn unsetFlag(self: *Self, flag: EntityFlags) void {
        self.flags.unset(@enumToInt(flag));
    }

    pub fn unsetFlags(self: *Self, flags: anytype) void {
        inline for (flags) |flag| {
            self.unsetFlag(flag);
        }
    }
};
