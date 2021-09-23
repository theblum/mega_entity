const std = @import("std");
const log = std.log.default;
const build_options = @import("build_options");
const m = @import("zlm");

const globals = &@import("globals.zig").globals;

const system = @import("systems.zig");
const platform = @import("platform.zig");

const Window = platform.Window;
const Input = platform.Input;
const Clock = platform.Clock;
const State = @import("state.zig").State;
const Renderer = @import("renderer.zig").Renderer;

const EntityManager = @import("entity_manager.zig").EntityManager;
const SystemManager = @import("system_manager.zig").SystemManager;

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

    globals.systemManager = SystemManager.init(&system.list);

    globals.window = try Window.init(build_options.programName, renderWidth, renderHeight, targetFPS);
    defer globals.window.deinit();

    globals.input = Input.init();

    globals.renderer = try Renderer.init(&globals.window);
    defer globals.renderer.deinit();

    globals.profiler = Profiler{};

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
            const template = "dt: 0.XXXX s/f, ec: XXXX";
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
