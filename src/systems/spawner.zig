const std = @import("std");
const log = std.log.scoped(.spawnerSystem);
const m = @import("zlm");

const State = @import("../state.zig").State;

pub fn tick(state: *State) void {
    state.profiler.start("Spawner System");

    const button = state.input.getMouseButton(.left);
    if (!button.wasDown and button.isDown) {
        const position = state.input.getMousePosition(state);
        const mass = (state.rand.float(f32) * 20.0) + 10.0;
        const radius = @sqrt(mass) * 5.0;

        var moverHandle = state.entityManager.createEntity(.{
            .position = position,
            .velocity = m.vec2(0.0, 0.0),
            .acceleration = m.vec2(0.0, 0.0),
            .mass = mass,
            .radius = radius,
            .color = m.vec4(0.6, 0.4, state.rand.float(f32), 0.8),
        }) catch |e| {
            log.err("Unable to create entity: {s}", .{e});
            return;
        };

        var moverPtr = state.entityManager.getEntityPtr(moverHandle) catch unreachable;
        moverPtr.setFlags(&.{ .isRenderable, .hasPhysics });
    }

    state.profiler.end();
}
