const std = @import("std");
const log = std.log.scoped(.gameStateChangerSystem);
const m = @import("zlm");

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const State = @import("../state.zig").State;
const GameStates = @import("../game_states.zig").GameStates;

pub fn tick(_: *State) void {
    gbls.profiler.start("Game State Changer");

    var changeGameState = false;
    const currentGameState = gbls.gameStateManager.current.?;
    var index = globals.engine.GameStateManager.indexOf(currentGameState);

    const qKey = gbls.window.input.getKey(.q);
    if (!qKey.wasDown and qKey.isDown) {
        index = @intCast(usize, @mod((@intCast(isize, index) - 1), GameStates.len));
        changeGameState = true;
    }

    const eKey = gbls.window.input.getKey(.e);
    if (!eKey.wasDown and eKey.isDown) {
        index = (index + 1) % GameStates.len;
        changeGameState = true;
    }

    if (changeGameState) {
        var nextGameState = globals.engine.GameStateManager.keyForIndex(index);
        gbls.gameStateManager.setTo(nextGameState, testTransFrom, testTransTo);
    }

    gbls.profiler.end();
}

var transitionColor = m.vec4(0.0, 0.0, 0.0, 0.0);
var transitionCurrentTime: f32 = 0.0;
const transitionMaxTime = 0.5;

fn testTransFrom(state: *State) bool {
    if (transitionCurrentTime > transitionMaxTime) {
        transitionCurrentTime = transitionMaxTime;
        return false;
    }

    transitionColor.w = transitionCurrentTime / transitionMaxTime;

    gbls.renderer.drawRectangle(
        .{ .x = gbls.window.size.x * 0.5, .y = gbls.window.size.y * 0.5 },
        .{ .x = gbls.window.size.x, .y = gbls.window.size.y },
        .{ .color = transitionColor },
    );

    transitionCurrentTime += state.deltaTime;

    return true;
}

fn testTransTo(state: *State) bool {
    if (transitionCurrentTime < 0.0) {
        transitionCurrentTime = 0.0;
        return false;
    }

    transitionColor.w = transitionCurrentTime / transitionMaxTime;

    gbls.renderer.drawRectangle(
        .{ .x = gbls.window.size.x * 0.5, .y = gbls.window.size.y * 0.5 },
        .{ .x = gbls.window.size.x, .y = gbls.window.size.y },
        .{ .color = transitionColor },
    );

    transitionCurrentTime -= state.deltaTime;

    return true;
}
