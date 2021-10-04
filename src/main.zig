const std = @import("std");
const log = std.log.default;
const build_options = @import("build_options");
const m = @import("zlm");

const globals = @import("globals.zig");
const systems = @import("systems.zig");

const gbls = &globals.gbls;

const State = @import("state.zig").State;
const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const GameStates = @import("game_states.zig").GameStates;

const Window = globals.engine.Window;
const Clock = globals.engine.Clock;
const Renderer = globals.engine.Renderer;
const EntityManager = globals.engine.EntityManager;
const GameStateManager = globals.engine.GameStateManager;

const Profiler = @import("profiler.zig").Profiler;

pub const renderWidth = 640;
pub const renderHeight = 360;
pub const scale = 2;
const targetFPS = 60;

pub fn main() anyerror!void {
    var state: State = undefined;

    var prng = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));
    gbls.rand = &prng.random;

    gbls.window = try Window.init(
        build_options.programName,
        renderWidth,
        renderHeight,
        .{ .targetFPS = targetFPS, .scale = scale, .keyRepeat = false },
    );
    defer gbls.window.deinit();
    gbls.window.addInput();

    gbls.renderer = try Renderer.init(&gbls.window);
    defer gbls.renderer.deinit();

    gbls.profiler = Profiler{};

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    gbls.entityManager = try EntityManager.init(&arena.allocator);
    defer gbls.entityManager.deinit();

    gbls.gameStateManager = GameStateManager.init(.gravitationalPull);
    defer gbls.gameStateManager.deinit(&state);
    gbls.gameStateManager.register(.bouncyBalls, &systems.bouncyBalls);
    gbls.gameStateManager.register(.randomDrag, &systems.randomDrag);
    gbls.gameStateManager.register(.playerMove, &systems.playerMove);
    gbls.gameStateManager.register(.gravitationalPull, &systems.gravitationalPull);

    var clock = try Clock.init();
    defer clock.deinit();
    while (gbls.window.isOpen()) {
        state.deltaTime = clock.getSecondsAndRestart();

        gbls.profiler.start("Entire Frame");

        gbls.renderer.clearWindow(m.vec4(0.2, 0.4, 0.6, 1.0));

        gbls.window.pollEvents();

        gbls.profiler.start("Run Systems");
        gbls.gameStateManager.run(&state);
        gbls.profiler.end();

        if (std.builtin.mode == .Debug) {
            const template = "dt: 0.XXXX s/f, ec: XXXX padding";
            var buffer: [template.len:0]u8 = .{0} ** template.len;
            _ = try std.fmt.bufPrint(
                &buffer,
                "dt: {d:.4} s/f, ec: {d:0>4}",
                .{ state.deltaTime, gbls.entityManager.entityCount },
            );

            gbls.renderer.drawText(
                &buffer,
                .{ .x = 5.0, .y = 5.0 },
                .{ .color = m.vec4(0.0, 1.0, 0.0, 1.0), .size = 11 },
            );
        }

        gbls.profiler.end();

        gbls.profiler.draw();
        gbls.profiler.reset();

        gbls.renderer.displayWindow();
    }
}
