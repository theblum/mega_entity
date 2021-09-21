const std = @import("std");
const log = std.log.default;
const build_options = @import("build_options");
const c = @import("c.zig");
const m = @import("zlm");

const platform = @import("platform.zig");
const Window = platform.Window;
const Clock = platform.Clock;
const State = @import("state.zig").State;
const Renderer = @import("renderer.zig").Renderer;

const EntityManager = @import("entity_manager.zig").EntityManager;
const SystemManager = @import("system_manager.zig").SystemManager;
const systemList = @import("systems.zig").systemList;

pub const renderWidth = 1280;
pub const renderHeight = 720;
const targetFPS = 60;

pub fn main() anyerror!void {
    var prng = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));
    const rand = &prng.random;

    var state: State = undefined;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    state.entityManager = try EntityManager.init(&arena.allocator);
    defer state.entityManager.deinit();

    var systemManager = SystemManager.init(&systemList);

    state.window = try Window.init(build_options.programName, renderWidth, renderHeight, targetFPS);
    defer state.window.deinit();

    state.renderer = try Renderer.init(&state.window);
    defer state.renderer.deinit();

    {
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            const mass = rand.float(f32) * 3.0;
            const radius = @sqrt(mass) * 20.0;

            var moverHandle = try state.entityManager.createEntity(.{
                .position = m.vec2(rand.float(f32) * state.window.width, rand.float(f32) * state.window.height),
                .velocity = m.vec2(0.0, 0.0),
                .acceleration = m.vec2(0.0, 0.0),
                .mass = mass,
                .radius = radius,
                .color = m.vec4(0.6, 0.4, rand.float(f32), 0.8),
            });

            var moverPtr = try state.entityManager.getEntityPtr(moverHandle);
            moverPtr.setFlags(&.{ .isRenderable, .hasPhysics });
        }
    }

    var clock = try Clock.init();
    defer clock.deinit();
    while (state.window.isOpen()) {
        state.dt = clock.getSecondsAndRestart();

        state.window.pollEvents();
        state.renderer.clearWindow(0x2288ddff);

        systemManager.tick(&state);

        if (std.builtin.mode == .Debug) {
            // @Note: Text will be: "0.XXXX s/f"
            var buffer: [11:0]u8 = undefined;
            _ = try std.fmt.bufPrintZ(&buffer, "{d:.4} s/f", .{state.dt});

            state.renderer.drawText(
                &buffer,
                .{ .x = 10.0, .y = 10.0 },
                .{ .color = m.vec4(0.0, 1.0, 0.0, 1.0), .size = 14 },
            );
        }

        state.renderer.displayWindow();
    }
}
