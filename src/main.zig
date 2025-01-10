const std = @import("std");

const Camera = @import("camera.zig").Camera;
const HitList = @import("hitlist.zig").HitList;
const Material = @import("material.zig").Material;
const MaterialType = @import("material.zig").Type;
const Sphere = @import("sphere.zig").Sphere;
const Vector = @import("vector.zig").Vector;

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

    const materialGround = Material{
        .albedo = Vector{ .x = 0.8, .y = 0.8, .z = 0.0 },
        .type = MaterialType.lambertian,
    };
    const materialCenter = Material{
        .albedo = Vector{ .x = 0.1, .y = 0.2, .z = 0.5 },
        .type = MaterialType.lambertian,
    };
    const materialLeft = Material{
        .albedo = Vector{ .x = 0.8, .y = 0.8, .z = 0.8 },
        .type = MaterialType.metal,
    };
    const materialRight = Material{
        .albedo = Vector{ .x = 0.8, .y = 0.6, .z = 0.2 },
        .type = MaterialType.metal,
    };

    try world.add(Sphere{
        .center = .{ .x = 0, .y = -100.5, .z = -1 },
        .radius = 100,
        .material = materialGround,
    });
    try world.add(Sphere{
        .center = .{ .x = 0, .y = 0, .z = -1.2 },
        .radius = 0.5,
        .material = materialCenter,
    });
    try world.add(Sphere{
        .center = .{ .x = -1, .y = 0, .z = -1 },
        .radius = 0.5,
        .material = materialLeft,
    });
    try world.add(Sphere{
        .center = .{ .x = 1, .y = 0, .z = -1 },
        .radius = 0.5,
        .material = materialRight,
    });

    var camera: Camera = Camera{};
    camera.aspectRatio = 16.0 / 9.0;
    camera.imageWidth = 400;
    camera.samplesPerPixel = 100;
    camera.maxDepth = 50;
    try camera.render(world);
}
