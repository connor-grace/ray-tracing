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
        .type = MaterialType.lambertian,
        .albedo = Vector{ .x = 0.8, .y = 0.8, .z = 0.0 },
    };
    const materialCenter = Material{
        .type = MaterialType.lambertian,
        .albedo = Vector{ .x = 0.1, .y = 0.2, .z = 0.5 },
    };
    const materialLeft = Material{
        .type = MaterialType.dialectric,
        .refractionIndex = 1.50,
    };
    const materialBubble = Material{
        .type = MaterialType.dialectric,
        .refractionIndex = 1.00 / 1.50,
    };
    const materialRight = Material{
        .type = MaterialType.metal,
        .albedo = Vector{ .x = 0.8, .y = 0.6, .z = 0.2 },
        .fuzz = 1.0,
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
        .center = .{ .x = -1, .y = 0, .z = -1 },
        .radius = 0.4,
        .material = materialBubble,
    });
    try world.add(Sphere{
        .center = .{ .x = 1, .y = 0, .z = -1 },
        .radius = 0.5,
        .material = materialRight,
    });

    // const r = @cos(std.math.pi / 4.0);

    // const materialLeft = Material{
    //     .type = MaterialType.lambertian,
    //     .albedo = Vector{ .x = 0, .y = 0, .z = 1 },
    // };
    // const materialRight = Material{
    //     .type = MaterialType.lambertian,
    //     .albedo = Vector{ .x = 1, .y = 0, .z = 0 },
    // };
    //
    // try world.add(Sphere{
    //     .center = .{ .x = -r, .y = 0, .z = -1 },
    //     .radius = r,
    //     .material = materialLeft,
    // });
    // try world.add(Sphere{
    //     .center = .{ .x = r, .y = 0, .z = -1 },
    //     .radius = r,
    //     .material = materialRight,
    // });

    var camera: Camera = Camera{};
    camera.aspectRatio = 16.0 / 9.0;
    camera.imageWidth = 400;
    camera.samplesPerPixel = 100;
    camera.maxDepth = 50;

    camera.verticalFov = 20;
    camera.lookFrom = Vector{ .x = -2, .y = 2, .z = 1 };
    camera.lookAt = Vector{ .x = 0, .y = 0, .z = -1 };
    camera.vUp = Vector{ .x = 0, .y = 1, .z = 0 };

    camera.defocusAngle = 10;
    camera.focusDistance = 3.4;

    try camera.render(world);
}
