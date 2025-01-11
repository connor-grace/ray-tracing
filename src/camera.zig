const std = @import("std");

const HitList = @import("hitlist.zig").HitList;
const HitRecord = @import("hitrecord.zig").HitRecord;
const Interval = @import("interval.zig").Interval;
const Material = @import("material.zig").Material;
const MaterialType = @import("material.zig").Type;
const Ray = @import("ray.zig").Ray;
const Vector = @import("vector.zig").Vector;

const dbg = std.debug.print;
var prng = std.rand.DefaultPrng.init(0);

pub const Camera = struct {
    aspectRatio: f64 = 1.0,
    imageWidth: u32 = 100,
    imageHeight: u32 = undefined,
    center: Vector = undefined,
    pixel00Location: Vector = undefined,
    pixelDeltaU: Vector = undefined,
    pixelDeltaV: Vector = undefined,
    samplesPerPixel: u32 = 10,
    pixelSamplesScale: f64 = undefined,
    maxDepth: u32 = 10,

    pub fn render(self: *Camera, world: HitList) !void {
        self.initialize();

        const stdout_file = std.io.getStdOut().writer();
        var bw = std.io.bufferedWriter(stdout_file);
        const stdout = bw.writer();

        try stdout.print("P3\n{d} {d}\n255\n", .{ self.imageWidth, self.imageHeight });

        for (0..self.imageHeight) |j| {
            dbg("Lines remaining: {d}\n", .{self.imageHeight - j});
            for (0..self.imageWidth) |i| {
                var pixelColor = Vector{ .x = 0, .y = 0, .z = 0 };
                for (0..self.samplesPerPixel) |_| {
                    const ray = self.getRay(@as(u32, @intCast(i)), @as(u32, @intCast(j)));
                    pixelColor = pixelColor.add(rayColor(ray, self.maxDepth, world));
                }
                try pixelColor.scale(self.pixelSamplesScale).printAsColor(stdout);
            }
        }
        dbg("Done.\n", .{});

        try bw.flush();
    }

    fn initialize(self: *Camera) void {
        self.imageHeight = @intFromFloat(@as(f64, @floatFromInt(self.imageWidth)) / self.aspectRatio);
        self.imageHeight = if (self.imageHeight < 1) 1 else self.imageHeight;

        self.pixelSamplesScale = 1.0 / @as(f64, @floatFromInt(self.samplesPerPixel));

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

    fn getRay(self: Camera, i: u32, j: u32) Ray {
        // Create ray from camera origin to randomly sampled point around i, j
        const offset = sampleSquare();
        const pixelSample = self.pixel00Location
            .add(self.pixelDeltaU.scale(@as(f64, @floatFromInt(i)) + offset.x))
            .add(self.pixelDeltaV.scale(@as(f64, @floatFromInt(j)) + offset.y));

        const rayOrigin = self.center;
        const rayDirection = pixelSample.sub(rayOrigin);

        return Ray{ .origin = rayOrigin, .direction = rayDirection };
    }

    fn sampleSquare() Vector {
        // Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
        const randX = prng.random().float(f64);
        const randY = prng.random().float(f64);

        //dbg("rx: {d}, ry: {d}", .{ randX, randY });

        return Vector{
            .x = randX - 0.5,
            .y = randY - 0.5,
            .z = 0,
        };
    }

    fn rayColor(ray: Ray, depth: u32, world: HitList) Vector {
        if (depth <= 0) return Vector{ .x = 0, .y = 0, .z = 0 };
        var hitRecord: HitRecord = undefined;
        const interval = Interval{ .min = 0.001, .max = std.math.inf(f64) };
        if (world.hit(ray, interval, &hitRecord)) {
            var scattered: Ray = undefined;
            var attenuation: Vector = undefined;
            if (hitRecord.material.scatter(ray, hitRecord, &attenuation, &scattered)) {
                return attenuation.mul(rayColor(scattered, depth - 1, world));
            }

            const direction = hitRecord.normal.add(Vector.randomUnitVector());
            return rayColor(Ray{
                .origin = hitRecord.point,
                .direction = direction,
            }, depth - 1, world).scale(0.7);
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
