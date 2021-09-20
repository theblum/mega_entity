const std = @import("std");
const log = std.log.scoped("systemManager");

const Entity = @import("entity.zig").Entity;
const State = @import("state.zig").State;
const SystemItem = @import("systems.zig").SystemItem;

pub const SystemManager = struct {
    const Self = @This();

    systems: []const SystemItem,

    pub fn init(systems: []const SystemItem) Self {
        return .{
            .systems = systems,
        };
    }

    pub fn tick(self: Self, state: *State) void {
        var iterator = state.entityManager.iterator();
        for (self.systems) |system| {
            while (iterator.next(system.flags)) |entity| {
                system.tickFn(entity, state);
            }
        }
    }
};
