const std = @import("std");
const log = std.log.scoped("systemManager");

const Entity = @import("entity.zig").Entity;
const State = @import("state.zig").State;

pub const SystemManager = struct {
    const Self = @This();

    systems: []const fn (*Entity, *State) void,

    pub fn init(systems: []const fn (*Entity, *State) void) Self {
        return .{
            .systems = systems,
        };
    }

    pub fn tick(self: Self, state: *State) void {
        // @Todo: Check flags each system needs and only call on entities that have those flags.
        // Currently each system individually checks flags and returns if entity doesn't have the required ones.
        for (self.systems) |system| {
            for (state.entityManager.entities) |*item| {
                if (item.entity) |*entity|
                    system(entity, state);
            }
        }
    }
};
