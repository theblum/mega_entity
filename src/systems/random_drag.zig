const std = @import("std");
const log = std.log.scoped(.randomDragSystem);
const m = @import("zlm");

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const State = @import("../state.zig").State;

const countMax = 5;

pub fn start(_: *State) bool {
    gbls.profiler.start("Drag Spawner Init");

    var count: usize = 0;
    while (count < countMax) : (count += 1) {
        const position = .{
            .x = gbls.rand.float(f32) * gbls.window.size.x,
            .y = gbls.rand.float(f32) * gbls.window.size.y,
        };
        const drag = gbls.rand.float(f32) * 5.0;
        const radius = drag * 5.0 + 20.0;

        var handle = gbls.entityManager.createEntity(.{
            .renderType = .circle,
            .position = position,
            .radius = radius,
            .drag = drag,
            .color = m.vec4(0.2, 0.8, 0.6, drag / 5.0),
        }) catch |e| {
            log.err("Unable to create entity: {s}", .{e});
            return false;
        };

        var ptr = gbls.entityManager.getEntityPtr(handle) catch unreachable;
        ptr.setFlags(&.{ .isRenderable, .hasDrag });
    }

    gbls.profiler.end();

    return true;
}

pub fn end(_: *State) void {
    return;
}
