const std = @import("std");
const Color = @import("color.zig").Color;
const Ray = @import("ray.zig").Ray;
const Vector = @import("vector.zig").Vector;

// Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
const dbg = std.debug.print;

fn rayColor(ray: Ray) Color {
    // Calculate lerp (linear blend): blendedValue = (1 − a) * startValue + a * endValue
    const unitDirection = ray.direction.unitVector();
    const a = 0.5 * (unitDirection.y + 1.0);
    const startColor = Color{
        .r = 1.0,
        .b = 1.0,
        .g = 1.0,
    };
    const endColor = Color{
        .r = 0.5,
        .b = 0.7,
        .g = 1.0,
    };
    return startColor.scale(1.0 - a).add(endColor.scale(a));
}

pub fn main() !void {
    const aspectRatio: f64 = 16.0 / 9.0;
    const imageWidth: u32 = 400;
    var imageHeight: u32 = @as(f64, imageWidth) / aspectRatio;
    imageHeight = if (imageHeight < 1) 1 else imageHeight;

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

            const pixelColor = rayColor(ray);
            try pixelColor.print(stdout);
        }
    }
    dbg("Done.\n", .{});

    try bw.flush();
}
