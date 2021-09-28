const std = @import("std");
const log = std.log.scoped(.ballSpawnerSystem);
const m = @import("zlm");

const globals = &@import("../globals.zig").globals;

const State = @import("../state.zig").State;

pub fn tick(_: *State) void {
    globals.profiler.start("Ball Spawner System");

    const button = globals.window.input.getMouseButton(.left);
    if (!button.wasDown and button.isDown) {
        const position = globals.window.input.getMousePosition();
        const mass = (globals.rand.float(f32) * 20.0) + 10.0;
        const radius = @sqrt(mass) * 5.0;

        var handle = globals.entityManager.createEntity(.{
            .renderType = .circle,
            .position = position,
            .velocity = m.vec2(0.0, 0.0),
            .acceleration = m.vec2(0.0, 0.0),
            .rotation = 0.0,
            .bounce = globals.rand.float(f32),
            .mass = mass,
            .radius = radius,
            .color = m.vec4(0.6, 0.4, globals.rand.float(f32), 0.8),
        }) catch |e| {
            log.err("Unable to create entity: {s}", .{e});
            return;
        };

        var ptr = globals.entityManager.getEntityPtr(handle) catch unreachable;
        ptr.setFlags(&.{ .isRenderable, .hasPhysics });
    }

    globals.profiler.end();
}
