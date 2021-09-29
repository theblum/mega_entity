const std = @import("std");
const log = std.log.scoped(.gameStateChangerSystem);

const globals = @import("../globals.zig");
const gbls = &globals.gbls;

const State = @import("../state.zig").State;
const GameStates = @import("../game_states.zig").GameStates;

pub fn tick(_: *State) void {
    gbls.profiler.start("Game State Changer System");

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
        gbls.gameStateManager.setTo(nextGameState);
    }
    gbls.profiler.end();
}
