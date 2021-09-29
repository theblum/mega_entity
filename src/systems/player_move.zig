const std = @import("std");
const log = std.log.scoped(.playerMoveSystem);
const m = @import("zlm");

const globals = &@import("../globals.zig").globals;

const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const EntityManager = @import("engine").EntityManager(Entity, EntityFlags);
const State = @import("../state.zig").State;

var time: f32 = 0.0;

var handle: EntityManager.Handle = undefined;

pub fn start(_: *State) bool {
    handle = globals.entityManager.createEntity(.{
        .renderType = .rectangle,
        .position = m.vec2(globals.window.size.x * 0.5, globals.window.size.y * 0.5),
        .rotation = 0.0,
        .size = m.vec2(20.0, 40.0),
        .color = m.vec4(0.8, 0.7, 0.6, 1.0),
    }) catch |e| {
        log.err("Unable to create player entity: {s}", .{e});
        return false;
    };

    var ptr = globals.entityManager.getEntityPtr(handle) catch unreachable;
    ptr.setFlags(&.{ .isRenderable, .isControllable });

    return false;
}

pub fn end(_: *State) void {
    globals.entityManager.deleteEntity(handle);
}

const flags = [_]EntityFlags{.isControllable};

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
        entity.position = entity.position.add(movement.scale(speed * state.deltaTime));

        time += state.deltaTime;
        entity.rotation = @sin(time * 5.0) * 180.0 / std.math.pi;
    }

    globals.profiler.end();
}
