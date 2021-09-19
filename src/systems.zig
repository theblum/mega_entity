const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const State = @import("state.zig").State;

const physics = @import("systems/physics.zig");
const render = @import("systems/render.zig");

pub const SystemItem = struct {
    tickFn: fn (*Entity, *State) void,
    flags: []const EntityFlags,
};

pub const systemList = [_]SystemItem{
    .{ .tickFn = physics.tick, .flags = &physics.flags },
    .{ .tickFn = render.tick, .flags = &render.flags },
};
