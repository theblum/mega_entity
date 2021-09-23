const std = @import("std");
const log = std.log.default;
const build_options = @import("build_options");
const m = @import("zlm");

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
    state.rand = &prng.random;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    state.entityManager = try EntityManager.init(&arena.allocator);
    defer state.entityManager.deinit();

    var systemManager = SystemManager.init(&system.list);

    state.window = try Window.init(build_options.programName, renderWidth, renderHeight, targetFPS);
    defer state.window.deinit();

    state.input = Input.init();

    state.renderer = try Renderer.init(&state.window);
    defer state.renderer.deinit();

    state.profiler = Profiler{};

    var clock = try Clock.init();
    defer clock.deinit();

    while (state.window.isOpen()) {
        state.dt = clock.getSecondsAndRestart();

        state.renderer.clearWindow(m.vec4(0.2, 0.4, 0.6, 1.0));
        state.profiler.draw(state.renderer);
        state.profiler.reset();

        state.profiler.start("Entire Frame");

        state.window.pollEvents(&state);

        state.profiler.start("Run Systems");
        systemManager.tick(&state);
        state.profiler.end();

        if (std.builtin.mode == .Debug) {
            const template = "dt: 0.XXXX s/f, ec: XXXX";
            var buffer: [template.len:0]u8 = .{0} ** template.len;
            _ = try std.fmt.bufPrint(
                &buffer,
                "dt: {d:.4} s/f, ec: {d:0>4}",
                .{ state.dt, state.entityManager.entityCount },
            );

            state.renderer.drawText(
                &buffer,
                .{ .x = 10.0, .y = 10.0 },
                .{ .color = m.vec4(0.0, 1.0, 0.0, 1.0), .size = 14 },
            );
        }

        state.profiler.start("Swap Buffers");
        state.renderer.displayWindow();
        state.profiler.end();

        state.profiler.end();
    }
}
