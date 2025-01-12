const std = @import("std");

const Camera = @import("camera.zig").Camera;
const HitList = @import("hitlist.zig").HitList;
const Material = @import("material.zig").Material;
const MaterialType = @import("material.zig").Type;
const Sphere = @import("sphere.zig").Sphere;
const Vector = @import("vector.zig").Vector;

const dbg = std.debug.print;
var prng = std.rand.DefaultPrng.init(0);

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
        .albedo = Vector{ .x = 0.5, .y = 0.5, .z = 0.5 },
    };
    try world.add(Sphere{
        .center = .{ .x = 0, .y = -1000, .z = 0 },
        .radius = 1000,
        .material = materialGround,
    });

    var a: i32 = -11;
    while (a < 11) : (a += 1) {
        var b: i32 = -11;
        while (b < 11) : (b += 1) {
            const chooseMaterial = prng.random().float(f64);
            const center = Vector{
                .x = @as(f64, @floatFromInt(a)) + 0.9 * prng.random().float(f64),
                .y = 0.2,
                .z = @as(f64, @floatFromInt(b)) + 0.9 * prng.random().float(f64),
            };

            if (center.sub(Vector{ .x = 4, .y = 0.2, .z = 0 }).length() > 0.9) {
                if (chooseMaterial < 0.8) {
                    try world.add(Sphere{
                        .center = center,
                        .radius = 0.2,
                        .material = Material{
                            .type = MaterialType.lambertian,
                            .albedo = Vector.random().mul(Vector.random()),
                        },
                    });
                } else if (chooseMaterial < 0.95) {
                    try world.add(Sphere{
                        .center = center,
                        .radius = 0.2,
                        .material = Material{
                            .type = MaterialType.metal,
                            .albedo = Vector.randomBound(0.5, 1),
                            .fuzz = Vector.randomF64(0, 0.5),
                        },
                    });
                } else {
                    try world.add(Sphere{
                        .center = center,
                        .radius = 0.2,
                        .material = Material{
                            .type = MaterialType.dialectric,
                            .refractionIndex = 1.5,
                        },
                    });
                }
            }
        }
    }

    const material1 = Material{
        .type = MaterialType.dialectric,
        .refractionIndex = 1.50,
    };
    try world.add(Sphere{
        .center = .{ .x = 0, .y = 1, .z = 0 },
        .radius = 1,
        .material = material1,
    });

    const material2 = Material{
        .type = MaterialType.lambertian,
        .albedo = Vector{ .x = 0.4, .y = 0.2, .z = 0.1 },
    };
    try world.add(Sphere{
        .center = .{ .x = -4, .y = 1, .z = 0 },
        .radius = 1,
        .material = material2,
    });

    const material3 = Material{
        .type = MaterialType.metal,
        .albedo = Vector{ .x = 0.8, .y = 0.6, .z = 0.2 },
        .fuzz = 1.0,
    };
    try world.add(Sphere{
        .center = .{ .x = 4, .y = 1, .z = 0 },
        .radius = 1,
        .material = material3,
    });

    var camera: Camera = Camera{};
    camera.aspectRatio = 16.0 / 9.0;
    camera.imageWidth = 1200;
    camera.samplesPerPixel = 500;
    camera.maxDepth = 50;

    camera.verticalFov = 20;
    camera.lookFrom = Vector{ .x = 13, .y = 2, .z = 3 };
    camera.lookAt = Vector{ .x = 0, .y = 0, .z = 0 };
    camera.vUp = Vector{ .x = 0, .y = 1, .z = 0 };

    camera.defocusAngle = 0.6;
    camera.focusDistance = 10;

    try camera.render(world);
}
