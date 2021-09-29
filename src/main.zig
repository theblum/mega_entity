const std = @import("std");
const log = std.log.default;
const build_options = @import("build_options");
const m = @import("zlm");

const globals = &@import("globals.zig").globals;
const systems = @import("systems.zig");

const State = @import("state.zig").State;
const Entity = @import("entity.zig").Entity;
const EntityFlags = @import("entity.zig").EntityFlags;
const GameStates = @import("game_states.zig").GameStates;

const Window = @import("engine").Window;
const Clock = @import("engine").Clock;
const Renderer = @import("engine").Renderer;
const EntityManager = @import("engine").EntityManager(Entity, EntityFlags);
const GameStateManager = @import("engine").GameStateManager(GameStates, State);

const Profiler = @import("profiler.zig").Profiler;

pub const renderWidth = 640;
pub const renderHeight = 360;
pub const scale = 2;
const targetFPS = 60;

pub fn main() anyerror!void {
    var state: State = undefined;

    var prng = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));
    globals.rand = &prng.random;

    globals.window = try Window.init(
        build_options.programName,
        renderWidth,
        renderHeight,
        .{ .targetFPS = targetFPS, .scale = scale, .keyRepeat = false },
    );
    defer globals.window.deinit();
    globals.window.addInput();

    globals.renderer = try Renderer.init(&globals.window);
    defer globals.renderer.deinit();

    globals.profiler = Profiler{};

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    globals.entityManager = try EntityManager.init(&arena.allocator);
    defer globals.entityManager.deinit();

    globals.gameStateManager = GameStateManager.init(.randomDrag);
    // @Todo: defer run current game state's `endFn`
    globals.gameStateManager.register(.bouncyBalls, &systems.bouncyBalls);
    globals.gameStateManager.register(.randomDrag, &systems.randomDrag);
    globals.gameStateManager.register(.playerMove, &systems.playerMove);

    var clock = try Clock.init();
    defer clock.deinit();
    while (globals.window.isOpen()) {
        state.deltaTime = clock.getSecondsAndRestart();

        globals.profiler.start("Entire Frame");

        globals.renderer.clearWindow(m.vec4(0.2, 0.4, 0.6, 1.0));

        globals.window.pollEvents();

        globals.profiler.start("Run Systems");
        globals.gameStateManager.run(&state);
        globals.profiler.end();

        if (std.builtin.mode == .Debug) {
            const template = "dt: 0.XXXX s/f, ec: XXXX padding";
            var buffer: [template.len:0]u8 = .{0} ** template.len;
            _ = try std.fmt.bufPrint(
                &buffer,
                "dt: {d:.4} s/f, ec: {d:0>4}",
                .{ state.deltaTime, globals.entityManager.entityCount },
            );

            globals.renderer.drawText(
                &buffer,
                .{ .x = 5.0, .y = 5.0 },
                .{ .color = m.vec4(0.0, 1.0, 0.0, 1.0), .size = 11 },
            );
        }

        globals.profiler.end();

        globals.profiler.draw();
        globals.profiler.reset();

        globals.renderer.displayWindow();
    }
}
