const std = @import("std");
const log = std.log.default;
const build_options = @import("build_options");
const m = @import("zlm");

const globals = &@import("globals.zig").globals;
const systems = @import("systems.zig");

const State = @import("state.zig").State;
const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const SystemItem = @import("systems.zig").SystemItem;

const Window = @import("engine").Window;
const Clock = @import("engine").Clock;
const Renderer = @import("engine").Renderer;
const EntityManager = @import("engine").EntityManager(Entity, EntityFlags);
const SystemManager = @import("engine").SystemManager(SystemItem, State);

const Profiler = @import("profiler.zig").Profiler;

pub const renderWidth = 1280;
pub const renderHeight = 720;
const targetFPS = 60;

pub fn main() anyerror!void {
    var state: State = undefined;

    var prng = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));
    globals.rand = &prng.random;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    globals.entityManager = try EntityManager.init(&arena.allocator);
    defer globals.entityManager.deinit();

    globals.systemManager = SystemManager.init(&systems.list);

    globals.window = try Window.init(
        build_options.programName,
        renderWidth,
        renderHeight,
        .{ .targetFPS = targetFPS, .keyRepeat = false },
    );
    defer globals.window.deinit();
    globals.window.addInput();

    globals.renderer = try Renderer.init(&globals.window);
    defer globals.renderer.deinit();

    globals.profiler = Profiler{};

    var playerHandle = try globals.entityManager.createEntity(.{
        .renderType = .rectangle,
        .position = m.vec2(globals.window.size.x * 0.5, globals.window.size.y * 0.5),
        .rotation = 0.0,
        .size = m.vec2(20.0, 40.0),
        .color = m.vec4(0.8, 0.7, 0.6, 1.0),
    });

    (try globals.entityManager.getEntityPtr(playerHandle)).setFlags(&.{ .isRenderable, .isControllable });

    var clock = try Clock.init();
    defer clock.deinit();
    while (globals.window.isOpen()) {
        state.dt = clock.getSecondsAndRestart();

        globals.renderer.clearWindow(m.vec4(0.2, 0.4, 0.6, 1.0));
        globals.profiler.draw();
        globals.profiler.reset();

        globals.profiler.start("Entire Frame");

        globals.window.pollEvents();

        globals.profiler.start("Run Systems");
        globals.systemManager.tick(&state);
        globals.profiler.end();

        if (std.builtin.mode == .Debug) {
            const template = "dt: 0.XXXX s/f, ec: XXXX padding";
            var buffer: [template.len:0]u8 = .{0} ** template.len;
            _ = try std.fmt.bufPrint(
                &buffer,
                "dt: {d:.4} s/f, ec: {d:0>4}",
                .{ state.dt, globals.entityManager.entityCount },
            );

            globals.renderer.drawText(
                &buffer,
                .{ .x = 10.0, .y = 10.0 },
                .{ .color = m.vec4(0.0, 1.0, 0.0, 1.0), .size = 14 },
            );
        }

        globals.profiler.start("Swap Buffers");
        globals.renderer.displayWindow();
        globals.profiler.end();

        globals.profiler.end();
    }
}
