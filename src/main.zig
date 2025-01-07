const std = @import("std");
const HitList = @import("hitlist.zig").HitList;
const HitRecord = @import("hitrecord.zig").HitRecord;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;
const Vector = @import("vector.zig").Vector;

// Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
const dbg = std.debug.print;

fn hitSphere(center: Vector, radius: f64, ray: Ray) f64 {
    const oc = center.sub(ray.origin);
    const a = ray.direction.lengthSquared();
    const h = ray.direction.dot(oc);
    const c = oc.lengthSquared() - radius * radius;
    const discriminant = h * h - a * c;

    if (discriminant < 0) {
        return -1;
    } else {
        return (h - std.math.sqrt(discriminant)) / a;
    }
}

fn rayColor(ray: Ray, world: HitList) Vector {
    var hitRecord: HitRecord = undefined;
    if (world.hit(ray, 0, std.math.floatMax(f64), &hitRecord)) {
        const color = Vector{ .x = 1, .y = 1, .z = 1 };
        return hitRecord.normal.add(color).scale(0.5);
    }

    // Calculate lerp (linear blend): blendedValue = (1 − a) * startValue + a * endValue
    const unitDirection = ray.direction.unitVector();
    const a = 0.5 * (unitDirection.y + 1.0);
    const startColor = Vector{
        .x = 1,
        .y = 1,
        .z = 1,
    };
    const endColor = Vector{
        .x = 0.5,
        .y = 0.7,
        .z = 1,
    };

    return startColor.scale(1.0 - a).add(endColor.scale(a));
}

pub fn main() !void {
    var generalPurposeAllocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = generalPurposeAllocator.allocator();
    defer {
        const deinitStatus = generalPurposeAllocator.deinit();
        if (deinitStatus == .leak) @panic("Memory leaked");
    }

    const aspectRatio: f64 = 16.0 / 9.0;
    const imageWidth: u32 = 400;
    var imageHeight: u32 = @as(f64, imageWidth) / aspectRatio;
    imageHeight = if (imageHeight < 1) 1 else imageHeight;

    var world: HitList = HitList{ .list = std.ArrayList(Sphere).init(gpa) };
    defer world.list.deinit();
    try world.add(.{ .center = .{ .x = 0, .y = 0, .z = -1 }, .radius = 0.5 });
    try world.add(.{ .center = .{ .x = 0, .y = -100.5, .z = -1 }, .radius = 100 });

    const focalLength: f64 = 1.0;
    const viewportHeight: f64 = 2.0;
    const viewportWidth: f64 = viewportHeight * (@as(f64, @floatFromInt(imageWidth)) / @as(f64, @floatFromInt(imageHeight)));
    const cameraCenter = Vector{
        .x = 0,
        .y = 0,
        .z = 0,
    };

    const viewportU = Vector{
        .x = viewportWidth,
        .y = 0,
        .z = 0,
    };
    const viewportV = Vector{
        .x = 0,
        .y = -viewportHeight,
        .z = 0,
    };

    const pixelDeltaU = viewportU.scale(1.0 / @as(f64, @floatFromInt(imageWidth)));
    const pixelDeltaV = viewportV.scale(1.0 / @as(f64, @floatFromInt(imageHeight)));

    const viewportUpperLeft = cameraCenter.sub(Vector{
        .x = 0,
        .y = 0,
        .z = focalLength,
    }).sub(viewportU.scale(0.5)).sub(viewportV.scale(0.5));

    const pixel00Location = viewportUpperLeft.add(pixelDeltaU.add(pixelDeltaV).scale(0.5));

    dbg("width: {d}, height: {d}\n", .{ imageWidth, imageHeight });

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{d} {d}\n255\n", .{ imageWidth, imageHeight });

    for (0..imageHeight) |y| {
        dbg("Lines remaining: {d}\n", .{imageHeight - y});
        for (0..imageWidth) |x| {
            const pixelCenter = pixel00Location.add(pixelDeltaU.scale(@floatFromInt(x))).add(pixelDeltaV.scale(@floatFromInt(y)));
            const rayDirection = pixelCenter.sub(cameraCenter);
            const ray = Ray{
                .origin = cameraCenter,
                .direction = rayDirection,
            };

            const pixelColor = rayColor(ray, world);
            try pixelColor.printAsColor(stdout);
        }
    }
    dbg("Done.\n", .{});

    try bw.flush();
}
