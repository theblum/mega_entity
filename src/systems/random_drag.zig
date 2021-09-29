const std = @import("std");
const log = std.log.scoped(.randomDragSystem);
const m = @import("zlm");

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const EntityManager = globals.engine.EntityManager;
const State = @import("../state.zig").State;

var handles: [5]EntityManager.Handle = undefined;

pub fn start(_: *State) bool {
    for (handles) |*handle| {
        const position = .{
            .x = gbls.rand.float(f32) * gbls.window.size.x,
            .y = gbls.rand.float(f32) * gbls.window.size.y,
        };
        const drag = gbls.rand.float(f32) * 5.0;
        const radius = drag * 5.0 + 20.0;

        handle.* = gbls.entityManager.createEntity(.{
            .renderType = .circle,
            .position = position,
            .radius = radius,
            .drag = drag,
            .color = m.vec4(0.2, 0.8, 0.6, drag / 5.0),
        }) catch |e| {
            log.err("Unable to create entity: {s}", .{e});
            return false;
        };

        var ptr = gbls.entityManager.getEntityPtr(handle.*) catch unreachable;
        ptr.setFlags(&.{ .isRenderable, .hasDrag });
    }

    return true;
}

var ballSpawnerHandles = &@import("ball_spawner.zig").handles;
var ballSpawnerHandlesCount = &@import("ball_spawner.zig").handlesCount;

pub fn end(_: *State) void {
    for (handles) |handle|
        gbls.entityManager.deleteEntity(handle);

    for (ballSpawnerHandles[0..ballSpawnerHandlesCount.*]) |handle|
        gbls.entityManager.deleteEntity(handle);

    ballSpawnerHandlesCount.* = 0;
}
