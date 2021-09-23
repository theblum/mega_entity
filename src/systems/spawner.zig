const std = @import("std");
const log = std.log.scoped(.spawnerSystem);
const m = @import("zlm");

const globals = &@import("../globals.zig").globals;

const State = @import("../state.zig").State;

pub fn tick(state: *State) void {
    _ = state;

    globals.profiler.start("Spawner System");

    const button = globals.input.getMouseButton(.left);
    if (!button.wasDown and button.isDown) {
        const position = globals.input.getMousePosition();
        const mass = (globals.rand.float(f32) * 20.0) + 10.0;
        const radius = @sqrt(mass) * 5.0;

        var moverHandle = globals.entityManager.createEntity(.{
            .position = position,
            .velocity = m.vec2(0.0, 0.0),
            .acceleration = m.vec2(0.0, 0.0),
            .mass = mass,
            .radius = radius,
            .color = m.vec4(0.6, 0.4, globals.rand.float(f32), 0.8),
        }) catch |e| {
            log.err("Unable to create entity: {s}", .{e});
            return;
        };

        var moverPtr = globals.entityManager.getEntityPtr(moverHandle) catch unreachable;
        moverPtr.setFlags(&.{ .isRenderable, .hasPhysics });
    }

    globals.profiler.end();
}
