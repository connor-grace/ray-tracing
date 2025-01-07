const std = @import("std");

const Camera = @import("camera.zig").Camera;
const HitList = @import("hitlist.zig").HitList;
const Sphere = @import("sphere.zig").Sphere;
const Vector = @import("vector.zig").Vector;

// Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
const dbg = std.debug.print;

pub fn main() !void {
    var generalPurposeAllocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = generalPurposeAllocator.allocator();
    defer {
        const deinitStatus = generalPurposeAllocator.deinit();
        if (deinitStatus == .leak) @panic("Memory leaked");
    }

    var world: HitList = HitList{ .list = std.ArrayList(Sphere).init(gpa) };
    defer world.list.deinit();
    try world.add(Sphere{ .center = .{ .x = 0, .y = 0, .z = -1 }, .radius = 0.5 });
    try world.add(Sphere{ .center = .{ .x = 0, .y = -100.5, .z = -1 }, .radius = 100 });

    var camera: Camera = Camera{};
    camera.aspectRatio = 16.0 / 9.0;
    camera.imageWidth = 400;
    try camera.render(world);
}
