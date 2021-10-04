const std = @import("std");
const log = std.log.scoped(.gravitationalPullSystem);
const m = @import("zlm");

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const EntityManager = globals.engine.EntityManager;
const Entity = @import("../entity.zig").Entity;
const EntityFlags = @import("../entity.zig").EntityFlags;
const State = @import("../state.zig").State;

const maxAttractorCount = 2;
const maxMoverCount = 5;

pub fn start(_: *State) bool {
    {
        var i: usize = 0;
        while (i < maxAttractorCount) : (i += 1) {
            const mass = gbls.rand.float(f32) * 10.0 + 30.0;
            const handle = gbls.entityManager.createEntity(.{
                .renderType = .circle,
                .physicsType = .attractor,
                .position = .{
                    .x = gbls.rand.float(f32) * gbls.window.size.x,
                    .y = gbls.rand.float(f32) * gbls.window.size.y,
                },
                .mass = mass,
                .radius = mass * 1.5,
                .color = m.vec4(0.2, 0.2, 0.8, 1.0),
            }) catch |e| {
                log.err("Unable to create entity: {s}", .{e});
                return false;
            };

            const ptr = gbls.entityManager.getEntityPtr(handle) catch unreachable;
            ptr.setFlags(&.{ .isRenderable, .hasPhysics });
        }
    }

    {
        var i: usize = 0;
        while (i < maxMoverCount) : (i += 1) {
            const mass = gbls.rand.float(f32) + 1.0;
            const handle = gbls.entityManager.createEntity(.{
                .renderType = .circle,
                .physicsType = .mover,
                .position = .{
                    .x = gbls.rand.float(f32) * gbls.window.size.x,
                    .y = gbls.rand.float(f32) * gbls.window.size.y,
                },
                // @Note: This allows the movers to orbit around the attractor
                .velocity = .{
                    .x = gbls.rand.float(f32) * 100.0 - 50.0,
                    .y = gbls.rand.float(f32) * 100.0 - 50.0,
                },
                .mass = mass,
                .radius = mass * 15.0,
                .color = m.vec4(0.6, 0.4, 0.2, 0.9),
            }) catch |e| {
                log.err("Unable to create entity: {s}", .{e});
                return false;
            };

            const ptr = gbls.entityManager.getEntityPtr(handle) catch unreachable;
            ptr.setFlags(&.{ .isRenderable, .hasPhysics });
        }
    }

    return true;
}

pub fn end(_: *State) void {
    var iterator = gbls.entityManager.iterator();
    while (iterator.next(&.{})) |item| {
        gbls.entityManager.deleteEntity(item.handle);
    }
}

const flags = [_]EntityFlags{.hasPhysics};

pub fn tick(state: *State) void {
    gbls.profiler.start("Grav. Pull System");

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

            const gravity = 250.0;
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

var draggedHandle: ?EntityManager.Handle = null;
var dragOffset: m.Vec2 = undefined;

pub fn tick2(_: *State) void {
    gbls.profiler.start("Grav. Pull Mouse System");

    var iterator = gbls.entityManager.iterator();
    while (iterator.next(&.{.hasPhysics})) |item| {
        var attractor = &item.entity.?;
        if (attractor.physicsType != .attractor)
            continue;

        const mouseButton = gbls.window.input.getMouseButton(.left);
        const mousePosition = gbls.window.input.getMousePosition();
        if (!mouseButton.wasDown and mouseButton.isDown and pointCircleCollide(mousePosition, attractor)) {
            draggedHandle = item.handle;
            attractor.color.w *= 0.8;
            dragOffset = gbls.window.input.getMousePosition();
        } else if (mouseButton.wasDown and !mouseButton.isDown) {
            if (draggedHandle) |handle| {
                (gbls.entityManager.getEntityPtr(handle) catch unreachable).color.w *= 1.25;
                draggedHandle = null;
            }
        }

        if (draggedHandle) |handle| {
            if (handle.index == item.handle.index) {
                attractor.position = attractor.position.add(mousePosition.sub(dragOffset));
                dragOffset = mousePosition;
            }
        }
    }

    gbls.profiler.end();
}

fn pointCircleCollide(point: m.Vec2, circle: *const Entity) bool {
    return point.sub(circle.position).length() < circle.radius;
}
