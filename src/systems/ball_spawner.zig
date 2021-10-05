const std = @import("std");
const log = std.log.scoped(.ballSpawnerSystem);
const m = @import("zlm");

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const EntityManger = globals.engine.EntityManager;
const State = @import("../state.zig").State;

pub fn tick(_: *State) void {
    gbls.profiler.start("Ball Spawner");

    const button = gbls.window.input.getMouseButton(.left);
    if (!button.wasDown and button.isDown) {
        const position = gbls.window.input.getMousePosition();
        const mass = (gbls.rand.float(f32) * 20.0) + 10.0;
        const radius = @sqrt(mass) * 5.0;

        var handle = gbls.entityManager.createEntity(.{
            .renderType = .circle,
            .position = position,
            .velocity = m.vec2(0.0, 0.0),
            .acceleration = m.vec2(0.0, 0.0),
            .rotation = 0.0,
            .bounce = gbls.rand.float(f32),
            .mass = mass,
            .radius = radius,
            .color = m.vec4(0.6, 0.4, gbls.rand.float(f32), 0.8),
        }) catch |e| {
            log.err("Unable to create entity: {s}", .{e});
            return;
        };

        var ptr = gbls.entityManager.getEntityPtr(handle) catch unreachable;
        ptr.setFlags(&.{ .isRenderable, .hasPhysics });
    }

    gbls.profiler.end();
}
