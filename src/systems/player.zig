const std = @import("std");
const log = std.log.scoped(.playerSystem);
const m = @import("zlm");

const globals = &@import("../globals.zig").globals;

const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

pub const flags = [_]EntityFlags{.isControllable};

var time: f32 = 0.0;

pub fn tick(state: *State) void {
    globals.profiler.start("Player System");

    var iterator = globals.entityManager.iterator();
    while (iterator.next(&flags)) |item| {
        var entity = &item.entity.?;

        const speed = 500.0;
        var movement = m.vec2(0.0, 0.0);

        const aKey = globals.window.input.getKey(.a);
        if (aKey.isDown)
            movement.x += -1.0;

        const dKey = globals.window.input.getKey(.d);
        if (dKey.isDown)
            movement.x += 1.0;

        const wKey = globals.window.input.getKey(.w);
        if (wKey.isDown)
            movement.y += -1.0;

        const sKey = globals.window.input.getKey(.s);
        if (sKey.isDown)
            movement.y += 1.0;

        movement = movement.normalize();
        entity.position = entity.position.add(movement.scale(speed * state.dt));

        time += state.dt;
        entity.rotation = @sin(time * 5.0) * 180.0 / std.math.pi;
    }

    globals.profiler.end();
}
