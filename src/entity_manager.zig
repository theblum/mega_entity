const std = @import("std");
const log = std.log.scoped(.entityManager);

const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;

pub const MAX_ENTITIES = 4096;

pub const EntityHandle = struct {
    index: usize,
    generation: u32,
};

const EntityItem = struct {
    handle: EntityHandle,
    entity: ?Entity = null,
};

pub const EntityManager = struct {
    const Self = @This();

    entities: []EntityItem,
    entityCount: usize = 0,
    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator) !Self {
        var entities = try allocator.alloc(EntityItem, MAX_ENTITIES);
        for (entities) |*e, i| {
            e.* = EntityItem{ .handle = .{ .index = i, .generation = 0 } };
        }

        var result = .{
            .entities = entities,
            .allocator = allocator,
        };

        return result;
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.entities);
    }

    pub fn createEntity(self: *Self, entity: Entity) !EntityHandle {
        var result: EntityHandle = undefined;

        if (self.entityCount >= self.entities.len) return error.ExceededMaxEntries;

        for (self.entities) |*item| {
            if (item.entity) |_| {} else {
                item.handle.generation += 1;
                item.entity = entity;

                result = item.handle;

                self.entityCount += 1;

                break;
            }
        } else return error.ExceededMaxEntities;

        return result;
    }

    pub fn deleteEntity(self: *Self, handle: EntityHandle) void {
        var item = &self.entities[handle.index];

        // @Note: This silently fails if the generations don't match.  Should this be the case?
        // Or should we return an error? Or not even check the generation?
        if (handle.generation == item.handle.generation) {
            item.entity = null;
            self.entityCount -= 1;
        }
    }

    pub fn getEntityPtr(self: Self, handle: EntityHandle) !*Entity {
        var item = &self.entities[handle.index];

        if (handle.generation != item.handle.generation) return error.GenerationMismatch;
        return if (item.entity) |*entity| entity else error.InvalidHandle;
    }

    pub fn iterator(self: *Self) Iterator {
        return .{
            .entityManager = self,
        };
    }

    const Iterator = struct {
        entityManager: *EntityManager,
        currentIndex: usize = 0,
        entitiesSeen: usize = 0,

        pub fn next(self: *@This(), flags: []const EntityFlags) ?*EntityItem {
            var manager = self.entityManager;
            var result = for (manager.entities[self.currentIndex..]) |*item| {
                self.currentIndex += 1;
                if (self.entitiesSeen >= manager.entityCount)
                    break null;

                if (item.entity) |entity| {
                    self.entitiesSeen += 1;
                    if (entity.hasFlags(flags))
                        break item;
                }
            } else null;

            return if (result) |r| r else blk: {
                self.reset();
                break :blk null;
            };
        }

        pub fn reset(self: *@This()) void {
            self.currentIndex = 0;
            self.entitiesSeen = 0;
        }
    };
};
