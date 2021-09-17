const std = @import("std");
const log = std.log.default;
const c = @import("c.zig");
const m = @import("zlm");

const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const EntityManager = @import("entity_manager.zig").EntityManager;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};
    var manager = try EntityManager.init(&gpa.allocator);
    defer manager.deinit();

    var entityHandle = try manager.createEntity(.{});
    var entityPtr = try manager.getEntityPtr(entityHandle);
    entityPtr.setFlags(.{ .isAlive, .isRenderable });
    entityPtr.position = m.vec2(3.0, 4.0);

    var entityHandle1 = try manager.createEntity(.{});
    var entityPtr1 = try manager.getEntityPtr(entityHandle1);
    entityPtr1.velocity = m.vec2(1.2, 3.4);

    manager.deleteEntity(entityHandle1);

    var newEntityHandle = try manager.createEntity(.{ .velocity = m.vec2(4.3, 2.1) });
    _ = manager.getEntityPtr(entityHandle1) catch |e| log.err("Couldn't get: {s}", .{e});
    var newEntityPtr = try manager.getEntityPtr(newEntityHandle);
    newEntityPtr.position = m.vec2(4.5, 5.6);
    newEntityPtr.setFlag(.isRenderable);

    log.info("entity: {s}", .{manager.entities[0]});
    log.info("entity: {s}", .{manager.entities[1]});
}
