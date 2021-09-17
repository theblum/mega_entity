const std = @import("std");
const log = std.log.default;
const c = @import("c.zig");
const m = @import("zlm");

const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const EntityManager = @import("entity_manager.zig").EntityManager;

const physicsSystem = @import("systems/physics.zig");
const renderSystem = @import("systems/render.zig");

pub const programName = "mega_entity" ++ if (std.builtin.mode == .Debug) "_debug" else "";
pub const renderWidth = 1280;
pub const renderHeight = 720;
const targetFPS = 60;

pub fn main() anyerror!void {
    var prng = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));
    const rand = &prng.random;

    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};
    var manager = try EntityManager.init(&gpa.allocator);
    defer manager.deinit();

    c.InitWindow(renderWidth, renderHeight, programName);
    defer c.CloseWindow();

    {
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            var moverHandle = try manager.createEntity(.{
                .position = m.vec2(rand.float(f32) * renderWidth, rand.float(f32) * renderHeight),
                .velocity = m.vec2(0.0, 0.0),
                .acceleration = m.vec2(0.0, 0.0),
                .mass = rand.float(f32) * 3.0,
                .color = m.vec4(0.6, 0.4, rand.float(f32), 0.95),
            });

            var moverPtr = try manager.getEntityPtr(moverHandle);
            moverPtr.setFlags(.{ .isRenderable, .hasPhysics });
        }
    }

    c.SetTargetFPS(targetFPS);
    while (!c.WindowShouldClose()) {
        const dt = c.GetFrameTime();

        physicsSystem.tick(&manager, dt);

        c.ClearBackground(.{ .r = 50, .g = 100, .b = 150, .a = 255 });
        c.BeginDrawing();

        renderSystem.tick(&manager, dt);

        if (std.builtin.mode == .Debug) {
            c.DrawText(programName, 10, 10, 20, c.LIME);
            c.DrawFPS(10, renderHeight - 30);
        }

        c.EndDrawing();
    }
}
