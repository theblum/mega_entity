const std = @import("std");
const log = std.log.scoped(.playerMoveSystem);
const m = @import("zlm");

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const EntityManager = globals.engine.EntityManager;
const State = @import("../state.zig").State;

var time: f32 = 0.0;

var handle: EntityManager.Handle = undefined;

pub fn start(_: *State) bool {
    handle = gbls.entityManager.createEntity(.{
        .renderType = .rectangle,
        .position = m.vec2(gbls.window.size.x * 0.5, gbls.window.size.y * 0.5),
        .rotation = 0.0,
        .size = m.vec2(20.0, 40.0),
        .color = m.vec4(0.8, 0.7, 0.6, 1.0),
    }) catch |e| {
        log.err("Unable to create player entity: {s}", .{e});
        return false;
    };

    var ptr = gbls.entityManager.getEntityPtr(handle) catch unreachable;
    ptr.setFlags(&.{ .isRenderable, .isControllable });

    return true;
}

pub fn end(_: *State) void {
    gbls.entityManager.deleteEntity(handle);
}

const flags = [_]EntityFlags{.isControllable};

pub fn tick(state: *State) void {
    gbls.profiler.start("Player System");

    var iterator = gbls.entityManager.iterator();
    while (iterator.next(&flags)) |item| {
        var entity = &item.entity.?;

        const speed = 500.0;
        var movement = m.vec2(0.0, 0.0);

        const aKey = gbls.window.input.getKey(.a);
        if (aKey.isDown)
            movement.x += -1.0;

        const dKey = gbls.window.input.getKey(.d);
        if (dKey.isDown)
            movement.x += 1.0;

        const wKey = gbls.window.input.getKey(.w);
        if (wKey.isDown)
            movement.y += -1.0;

        const sKey = gbls.window.input.getKey(.s);
        if (sKey.isDown)
            movement.y += 1.0;

        movement = movement.normalize();
        entity.position = entity.position.add(movement.scale(speed * state.deltaTime));

        time += state.deltaTime;
        entity.rotation = @sin(time * 5.0) * 180.0 / std.math.pi;
    }

    gbls.profiler.end();
}
