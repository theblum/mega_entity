const std = @import("std");
const log = std.log.default;
const c = @import("c.zig");
const m = @import("zlm");

const State = @import("state.zig").State;

const EntityManager = @import("entity_manager.zig").EntityManager;
const SystemManager = @import("system_manager.zig").SystemManager;
const systemList = @import("systems.zig").systemList;

pub const programName = "mega_entity" ++ if (std.builtin.mode == .Debug) "_debug" else "";
pub const renderWidth = 1280;
pub const renderHeight = 720;
const targetFPS = 60;

pub fn main() anyerror!void {
    var prng = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp()));
    const rand = &prng.random;

    var state: State = undefined;
    state.renderWidth = renderWidth;
    state.renderHeight = renderHeight;

    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};
    state.entityManager = try EntityManager.init(&gpa.allocator);
    defer state.entityManager.deinit();

    var systemManager = SystemManager.init(&systemList);

    // @Note: These are all just the default settings except for `antialiasingLevel`.
    // Also, as per the documentation: All these settings with the exception of the compatibility
    // flag and anti-aliasing level have no impact on the regular SFML rendering (graphics module),
    // so you may need to use this structure only if you're using SFML as a windowing system for
    // custom OpenGL rendering.
    const settings = .{
        .depthBits = 0,
        .stencilBits = 0,
        .antialiasingLevel = 8,
        .majorVersion = 1,
        .minorVersion = 1,
        .attributeFlags = c.sfContextDefault,
        .sRgbCapable = c.sfFalse,
    };

    state.window = c.sfRenderWindow_create(
        .{ .width = renderWidth, .height = renderHeight, .bitsPerPixel = 32 },
        programName,
        c.sfDefaultStyle,
        &settings,
    ) orelse return error.WindowCreationFailed;
    defer c.sfRenderWindow_destroy(state.window);

    state.font = c.sfFont_createFromFile("resources/iosevka.ttf") orelse return error.FontLoadingError;
    defer c.sfFont_destroy(state.font);

    state.circle = c.sfCircleShape_create().?;
    defer c.sfCircleShape_destroy(state.circle);

    c.sfRenderWindow_setVerticalSyncEnabled(state.window, c.sfFalse);
    c.sfRenderWindow_setFramerateLimit(state.window, targetFPS);

    {
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            var moverHandle = try state.entityManager.createEntity(.{
                .position = m.vec2(rand.float(f32) * renderWidth, rand.float(f32) * renderHeight),
                .velocity = m.vec2(0.0, 0.0),
                .acceleration = m.vec2(0.0, 0.0),
                .mass = rand.float(f32) * 3.0,
                .color = m.vec4(0.6, 0.4, rand.float(f32), 0.8),
            });

            var moverPtr = try state.entityManager.getEntityPtr(moverHandle);
            moverPtr.setFlags(&.{ .isRenderable, .hasPhysics });
        }
    }

    var clock = c.sfClock_create();
    defer c.sfClock_destroy(clock);
    while (c.sfRenderWindow_isOpen(state.window) == c.sfTrue) {
        state.dt = c.sfTime_asSeconds(c.sfClock_restart(clock));

        var event: c.sfEvent = undefined;
        while (c.sfRenderWindow_pollEvent(state.window, &event) == c.sfTrue) {
            if (event.type == c.sfEvtClosed)
                c.sfRenderWindow_close(state.window);
        }

        c.sfRenderWindow_clear(state.window, c.sfColor_fromInteger(0x2288ddff));

        systemManager.tick(&state);

        if (std.builtin.mode == .Debug) {
            // @Note: Text will be: "0.XXXX s/f"
            var buffer: [11:0]u8 = undefined;
            _ = try std.fmt.bufPrintZ(&buffer, "{d:.4} s/f", .{state.dt});

            var spfText = c.sfText_create();
            defer c.sfText_destroy(spfText);

            c.sfText_setString(spfText, &buffer);
            c.sfText_setFont(spfText, state.font);
            c.sfText_setCharacterSize(spfText, 14);
            c.sfText_setFillColor(spfText, c.sfGreen);

            var rect = c.sfText_getGlobalBounds(spfText);

            c.sfText_setPosition(spfText, .{ .x = renderWidth - 10.0 - rect.width, .y = 10.0 });
            c.sfRenderWindow_drawText(state.window, spfText, null);
        }

        c.sfRenderWindow_display(state.window);
    }
}
