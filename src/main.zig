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

    var clock = try Clock.init();
    defer clock.deinit();

    while (state.window.isOpen()) {
        state.dt = clock.getSecondsAndRestart();

        state.window.pollEvents(&state);
        state.renderer.clearWindow(m.vec4(0.2, 0.4, 0.6, 1.0));

        systemManager.tick(&state);

        if (std.builtin.mode == .Debug) {
            // @Note: "0.XXXX s/f"
            var spfBuffer: [10:0]u8 = .{0} ** 10;
            _ = try std.fmt.bufPrint(&spfBuffer, "{d:.4} s/f", .{state.dt});

            state.renderer.drawText(
                &spfBuffer,
                .{ .x = 10.0, .y = 10.0 },
                .{ .color = m.vec4(0.0, 1.0, 0.0, 1.0), .size = 14 },
            );

            // @Note: "Entity Count: XXXX"
            var countBuffer: [18:0]u8 = .{0} ** 18;
            _ = try std.fmt.bufPrint(&countBuffer, "Entity Count: {d:0>4}", .{state.entityManager.entityCount});

            state.renderer.drawText(
                &countBuffer,
                .{ .x = 10.0, .y = 25.0 },
                .{ .color = m.vec4(0.0, 1.0, 0.0, 1.0), .size = 14 },
            );
        }

        state.renderer.displayWindow();
    }
}
