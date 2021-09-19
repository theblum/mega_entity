const Entity = @import("entity.zig").Entity;
const State = @import("state.zig").State;

const physics = @import("systems/physics.zig").tick;
const render = @import("systems/render.zig").tick;

pub const systemList = [_]fn (*Entity, *State) void{
    physics,
    render,
};
