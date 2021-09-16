const std = @import("std");
const log = std.log.scoped(.entityManager);

const Entity = @import("entity.zig").Entity;

pub const MAX_ENTITIES = 1024;

pub const EntityHandle = struct {
    id: usize,
    generation: u32,
};

const EntityItem = struct {
    generation: u32 = 0,
    entity: ?Entity = null,
};

pub const EntityManager = struct {
    const Self = @This();

    entities: []EntityItem,
    entityCount: usize = 0,

    allocator: *std.mem.Allocator,

    pub fn init(allocator: *std.mem.Allocator) !Self {
        var entities = try allocator.alloc(EntityItem, MAX_ENTITIES);
        for (entities) |*e| {
            e.* = EntityItem{};
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

    pub fn createEntity(self: *Self) !EntityHandle {
        if (!(self.entityCount < MAX_ENTITIES))
            return error.ExceededMaxEntities;

        self.entityCount += 1;
        var result: EntityHandle = undefined;

        for (self.entities) |*item, i| {
            if (item.entity) |_| {} else {
                item.generation += 1;
                item.entity = Entity{};

                result.id = i;
                result.generation = item.generation;

                break;
            }
        }

        return result;
    }

    pub fn deleteEntity(self: *Self, handle: EntityHandle) void {
        for (self.entities) |*item, i| {
            // @Note: Do I need to worry about checking the generation here?
            if (handle.id == i and handle.generation == item.generation)
                item.entity = null;
        }
    }

    pub fn getEntityPtr(self: Self, handle: EntityHandle) !*Entity {
        var item = for (self.entities) |*item, i| {
            if (handle.id == i) {
                if (handle.generation != item.generation)
                    return error.GenerationMismatch;

                break item;
            }
        } else return error.InvalidHandle;

        return if (item.entity) |*e| e else error.InvalidHandle;
    }
};
