const std = @import("std");

const HitList = @import("hitlist.zig").HitList;
const HitRecord = @import("hitrecord.zig").HitRecord;
const Interval = @import("interval.zig").Interval;
const Ray = @import("ray.zig").Ray;
const Vector = @import("vector.zig").Vector;

const dbg = std.debug.print;

pub const Camera = struct {
    aspectRatio: f64 = 1.0,
    imageWidth: u32 = 100,
    imageHeight: u32 = undefined,
    center: Vector = undefined,
    pixel00Location: Vector = undefined,
    pixelDeltaU: Vector = undefined,
    pixelDeltaV: Vector = undefined,

    pub fn render(self: *Camera, world: HitList) !void {
        self.initialize();

        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();

        try stdout.print("P3\n{d} {d}\n255\n", .{ self.imageWidth, self.imageHeight });

        for (0..self.imageHeight) |y| {
            dbg("Lines remaining: {d}\n", .{self.imageHeight - y});
            for (0..self.imageWidth) |x| {
                const pixelCenter = self.pixel00Location.add(self.pixelDeltaU.scale(@floatFromInt(x))).add(self.pixelDeltaV.scale(@floatFromInt(y)));
                const rayDirection = pixelCenter.sub(self.center);
                const ray = Ray{
                    .origin = self.center,
                    .direction = rayDirection,
                };

                const pixelColor = rayColor(ray, world);
                try pixelColor.printAsColor(stdout);
            }
        }
        dbg("Done.\n", .{});

        try bw.flush();
    }

    fn initialize(self: *Camera) void {
        self.imageHeight = @intFromFloat(@as(f64, @floatFromInt(self.imageWidth)) / self.aspectRatio);
        self.imageHeight = if (self.imageHeight < 1) 1 else self.imageHeight;

        const focalLength: f64 = 1.0;
        const viewportHeight: f64 = 2.0;
        const viewportWidth: f64 = viewportHeight * (@as(f64, @floatFromInt(self.imageWidth)) / @as(f64, @floatFromInt(self.imageHeight)));

        self.center = Vector{ .x = 0, .y = 0, .z = 0 };

        const viewportU = Vector{ .x = viewportWidth, .y = 0, .z = 0 };
        const viewportV = Vector{ .x = 0, .y = -viewportHeight, .z = 0 };

        self.pixelDeltaU = viewportU.scale(1.0 / @as(f64, @floatFromInt(self.imageWidth)));
        self.pixelDeltaV = viewportV.scale(1.0 / @as(f64, @floatFromInt(self.imageHeight)));

        const viewportUpperLeft = self.center.sub(Vector{
            .x = 0,
            .y = 0,
            .z = focalLength,
        }).sub(viewportU.scale(0.5)).sub(viewportV.scale(0.5));

        self.pixel00Location = viewportUpperLeft.add(self.pixelDeltaU.add(self.pixelDeltaV).scale(0.5));
    }

    fn rayColor(ray: Ray, world: HitList) Vector {
        var hitRecord: HitRecord = undefined;
        const interval = Interval{ .min = 0, .max = std.math.inf(f64) };
        if (world.hit(ray, interval, &hitRecord)) {
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
};
