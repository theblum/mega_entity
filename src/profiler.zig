const std = @import("std");
const log = std.log.scoped(.profiler);
const m = @import("zlm");

const globals = @import("globals.zig");
const gbls = &globals.gbls;

const Frame = struct {
    label: []const u8,

    started: bool = false,
    ended: bool = false,
    level: u32 = 0,

    start: i128,
    end: i128,
};

const MAX_FRAMES = 256;

pub const Profiler = struct {
    const Self = @This();

    frames: [MAX_FRAMES]Frame = .{std.mem.zeroInit(Frame, .{})} ** MAX_FRAMES,
    frameCount: usize = 0,
    currentFrame: usize = 0,
    currentLevel: u32 = 0,

    pub fn start(self: *Self, label: []const u8) void {
        while (self.frames[self.currentFrame].started)
            self.currentFrame += 1;

        var frame = &self.frames[self.currentFrame];
        frame.* = .{
            .label = label,
            .started = true,
            .level = self.currentLevel,
            .start = std.time.nanoTimestamp(),
            .end = undefined,
        };

        self.frameCount += 1;
        self.currentLevel += 1;
    }

    pub fn end(self: *Self) void {
        var frame = &self.frames[self.currentFrame];
        frame.end = std.time.nanoTimestamp();
        frame.ended = true;

        self.currentLevel -= 1;

        if (self.currentFrame > 0)
            self.currentFrame -= 1;

        while (self.currentFrame > 0) : (self.currentFrame -= 1) {
            var prevFrame = &self.frames[self.currentFrame];
            if (prevFrame.level < self.currentLevel)
                break;
        }
    }

    pub fn reset(self: *Self) void {
        for (self.frames[0..self.frameCount]) |*frame| {
            frame.started = false;
            frame.ended = false;
        }

        self.frameCount = 0;
        self.currentFrame = 0;
        self.currentLevel = 0;
    }

    pub fn draw(self: Self) void {
        for (self.frames[0..self.frameCount]) |frame, i| {
            if (!frame.ended) {
                log.err("frame '{s}' never ended...skipping", .{frame.label});
                continue;
            }

            var spaces: [32]u8 = .{' '} ** 32;
            var dots: [32]u8 = .{'.'} ** 32;

            const numSpaces = frame.level * 2;
            const numDots = dots.len - frame.label.len - numSpaces;

            const elapsedMillis = @intToFloat(f64, frame.end - frame.start) / std.time.ns_per_ms;

            const template = "LABEL ........................... XX.XXXms padding";
            var buffer: [template.len:0]u8 = .{0} ** template.len;
            _ = std.fmt.bufPrint(
                &buffer,
                "{s}{s} {s}{d: >7.3}ms",
                .{ spaces[0..numSpaces], frame.label, dots[0..numDots], elapsedMillis },
            ) catch {
                log.err("buffer too short for frame '{s}'...skipping", .{frame.label});
                continue;
            };

            gbls.renderer.drawText(
                &buffer,
                .{ .x = 5.0, .y = 16.0 + (11.0 * @intToFloat(f32, i)) },
                .{ .color = m.vec4(0.0, 1.0, 0.0, 1.0), .size = 11 },
            );
        }
    }
};
