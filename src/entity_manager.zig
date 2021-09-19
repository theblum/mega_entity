const std = @import("std");
const log = std.log.scoped(.entityManager);

const Entity = @import("entity.zig").Entity;

pub const MAX_ENTITIES = 1024;

const EntityHandle = struct {
    index: usize,
    generation: u32,
};

const EntityItem = struct {
    generation: u32 = 0,
    entity: ?Entity = null,
};

pub const EntityManager = struct {
    const Self = @This();

    entities: []EntityItem,
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

    pub fn createEntity(self: *Self, entity: Entity) !EntityHandle {
        var result: EntityHandle = undefined;

        for (self.entities) |*item, i| {
            if (item.entity) |_| {} else {
                item.generation += 1;
                item.entity = entity;

                result.index = i;
                result.generation = item.generation;

                break;
            }
        } else return error.ExceededMaxEntities;

        return result;
    }

    pub fn deleteEntity(self: *Self, handle: EntityHandle) void {
        var item = &self.entities[handle.index];

        // @Note: This silently fails if the generations don't match.  Should this be the case?
        // Or should we return an error? Or not even check the generation?
        if (handle.generation == item.generation)
            item.entity = null;
    }

    pub fn getEntityPtr(self: Self, handle: EntityHandle) !*Entity {
        var item = &self.entities[handle.index];

        if (handle.generation != item.generation) return error.GenerationMismatch;
        return if (item.entity) |*entity| entity else error.InvalidHandle;
    }
};
