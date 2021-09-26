const std = @import("std");
const log = std.log.scoped(.dragSpawnerSystem);
const m = @import("zlm");

const globals = &@import("../globals.zig").globals;

const State = @import("../state.zig").State;

var count: usize = 0;
const countMax = 5;

pub fn tick(state: *State) void {
    _ = state;

    globals.profiler.start("Drag Spawner System");

    while (count < countMax) : (count += 1) {
        const position = .{
            .x = globals.rand.float(f32) * globals.window.size.x,
            .y = globals.rand.float(f32) * globals.window.size.y,
        };
        const drag = globals.rand.float(f32) * 5.0;
        const radius = drag * 5.0 + 20.0;

        var handle = globals.entityManager.createEntity(.{
            .renderType = .circle,
            .position = position,
            .radius = radius,
            .drag = drag,
            .color = m.vec4(0.2, 0.8, 0.6, drag / 5.0),
        }) catch |e| {
            log.err("Unable to create entity: {s}", .{e});
            return;
        };

        var ptr = globals.entityManager.getEntityPtr(handle) catch unreachable;
        ptr.setFlags(&.{ .isRenderable, .hasDrag });
    }

    globals.profiler.end();
}
