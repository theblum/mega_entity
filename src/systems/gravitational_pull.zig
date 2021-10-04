const std = @import("std");
const log = std.log.scoped(.gravitationalPullSystem);
const m = @import("zlm");

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const EntityManager = globals.engine.EntityManager;
const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

var handles: [10]EntityManager.Handle = undefined;

pub fn start(_: *State) bool {
    handles[0] = gbls.entityManager.createEntity(.{
        .renderType = .circle,
        .physicsType = .attractor,
        .position = .{
            .x = gbls.rand.float(f32) * gbls.window.size.x,
            .y = gbls.rand.float(f32) * gbls.window.size.y,
        },
        .mass = 20.0,
        .radius = 50.0,
        .color = m.vec4(0.2, 0.2, 0.8, 1.0),
    }) catch |e| {
        log.err("Unable to create entity: {s}", .{e});
        return false;
    };

    var ptr = gbls.entityManager.getEntityPtr(handles[0]) catch unreachable;
    ptr.setFlags(&.{ .isRenderable, .hasPhysics });

    for (handles[1..]) |*handle| {
        var mass = gbls.rand.float(f32) + 1.0;
        handle.* = gbls.entityManager.createEntity(.{
            .renderType = .circle,
            .physicsType = .mover,
            .position = .{
                .x = gbls.rand.float(f32) * gbls.window.size.x,
                .y = gbls.rand.float(f32) * gbls.window.size.y,
            },
            .mass = mass,
            .radius = mass * 15.0,
            .color = m.vec4(0.6, 0.4, 0.2, 0.9),
        }) catch |e| {
            log.err("Unable to create entity: {s}", .{e});
            return false;
        };

        ptr = gbls.entityManager.getEntityPtr(handle.*) catch unreachable;
        ptr.setFlags(&.{ .isRenderable, .hasPhysics });
    }

    return true;
}

pub fn end(_: *State) void {
    for (handles) |handle|
        gbls.entityManager.deleteEntity(handle);
}

const flags = [_]EntityFlags{.hasPhysics};

pub fn tick(state: *State) void {
    gbls.profiler.start("Gravitational Pull System");

    var iterator = gbls.entityManager.iterator();
    while (iterator.next(&flags)) |item| {
        var attractor = &item.entity.?;
        if (attractor.physicsType != .attractor)
            continue;

        var iterator2 = gbls.entityManager.iterator();
        inner: while (iterator2.next(&flags)) |item2| {
            var mover = &item2.entity.?;
            if (mover.physicsType != .mover)
                continue :inner;

            const gravity = 500.0;
            var force = attractor.position.sub(mover.position);
            var distanceSq = force.length2();
            distanceSq = @minimum(300.0, @maximum(25.0, distanceSq));
            force = force.normalize();
            const strength = (gravity * attractor.mass * mover.mass) / distanceSq;
            force = force.scale(strength);

            applyForce(mover, force);

            mover.velocity = mover.velocity.add(mover.acceleration.scale(state.deltaTime));
            mover.position = mover.position.add(mover.velocity.scale(state.deltaTime));
            mover.acceleration = mover.acceleration.scale(0.0);
        }
    }

    gbls.profiler.end();
}

fn applyForce(entity: *Entity, force: m.Vec2) void {
    entity.acceleration = entity.acceleration.add(force.scale(1.0 / entity.mass));
}
