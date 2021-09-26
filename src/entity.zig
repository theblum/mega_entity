const std = @import("std");
const log = std.log.scoped(.entity);
const m = @import("zlm");

pub const EntityFlags = enum {
    const len = @typeInfo(@This()).Enum.fields.len;

    isAlive,
    isRenderable,
    hasPhysics,
    hasDrag,
    isControllable,
};

pub const Entity = struct {
    flags: std.StaticBitSet(EntityFlags.len) = std.StaticBitSet(EntityFlags.len).initEmpty(),

    renderType: RenderTypes = .none,
    position: m.Vec2 = undefined,
    velocity: m.Vec2 = undefined,
    acceleration: m.Vec2 = undefined,
    rotation: f32 = undefined,
    bounce: f32 = undefined,
    drag: f32 = undefined,
    mass: f32 = undefined,
    size: m.Vec2 = undefined,
    radius: f32 = undefined,
    color: m.Vec4 = undefined,

    pub const RenderTypes = enum {
        none,
        circle,
        rectangle,
        text,
        sprite,
    };

    pub usingnamespace FlagUtils(@This());
};

fn FlagUtils(comptime T: type) type {
    return struct {
        const Self = T;

        pub fn hasFlag(self: Self, flag: EntityFlags) bool {
            return self.flags.isSet(@enumToInt(flag));
        }

        pub fn hasFlags(self: Self, flags: []const EntityFlags) bool {
            var result = true;

            for (flags) |flag| {
                if (!self.hasFlag(flag)) {
                    result = false;
                    break;
                }
            }

            return result;
        }

        pub fn setFlag(self: *Self, flag: EntityFlags) void {
            self.flags.set(@enumToInt(flag));
        }

        pub fn setFlags(self: *Self, flags: []const EntityFlags) void {
            for (flags) |flag| {
                self.setFlag(flag);
            }
        }

        pub fn unsetFlag(self: *Self, flag: EntityFlags) void {
            self.flags.unset(@enumToInt(flag));
        }

        pub fn unsetFlags(self: *Self, flags: []const EntityFlags) void {
            for (flags) |flag| {
                self.unsetFlag(flag);
            }
        }
    };
}
