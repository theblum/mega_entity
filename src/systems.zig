const std = @import("std");
const log = std.log.scoped(.systems);

const Entity = @import("entity.zig").Entity;
const EntityHandle = @import("entity_manager.zig").EntityHandle;
const EntityFlags = @import("entity.zig").EntityFlags;
const State = @import("state.zig").State;

const physics = @import("systems/physics.zig");
const render = @import("systems/render.zig");

pub const SystemItem = struct {
    tickFn: fn (*Entity, EntityHandle, *State) void,
    flags: []const EntityFlags,
};

pub const systemList = [_]SystemItem{
    .{ .tickFn = physics.tick, .flags = &physics.flags },
    .{ .tickFn = render.tick, .flags = &render.flags },
};
