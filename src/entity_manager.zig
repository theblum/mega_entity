const std = @import("std");
const log = std.log.scoped(.entityManager);

const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;

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
    iterator: Iterator,

    pub fn init(allocator: *std.mem.Allocator) !Self {
        var entities = try allocator.alloc(EntityItem, MAX_ENTITIES);
        for (entities) |*e| {
            e.* = EntityItem{};
        }

        // @Todo: Figure out why `iterator` can't be created directly in the `result` struct.
        // Currently it looks as though the `iterator.currentIndex` field gets uninitialized.
        // Is this because `init` can return an error?
        var iterator = Iterator{};
        var result = .{
            .entities = entities,
            .allocator = allocator,
            .iterator = iterator,
        };

        log.info("init: {d}", .{result.iterator.currentIndex});

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

    const Iterator = struct {
        currentIndex: usize = 0,

        pub fn next(iterator: *@This(), flags: []const EntityFlags) ?*Entity {
            const self = @fieldParentPtr(Self, "iterator", iterator);

            return for (self.entities[iterator.currentIndex..]) |*item| {
                iterator.currentIndex += 1;
                if (item.entity) |*entity|
                    if (entity.hasFlags(flags))
                        break entity;
            } else blk: {
                iterator.reset();
                break :blk null;
            };
        }

        pub fn reset(iterator: *@This()) void {
            iterator.currentIndex = 0;
        }
    };
};
