const std = @import("std");

const Interval = @import("interval.zig").Interval;

var prng = std.rand.DefaultPrng.init(0);

pub const Vector = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn add(self: Vector, other: Vector) Vector {
        return Vector{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vector, other: Vector) Vector {
        return Vector{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn mul(self: Vector, other: Vector) Vector {
        return Vector{
            .x = self.x * other.x,
            .y = self.y * other.y,
            .z = self.z * other.z,
        };
    }

    pub fn scale(self: Vector, scalar: f64) Vector {
        return Vector{
            .x = self.x * scalar,
            .y = self.y * scalar,
            .z = self.z * scalar,
        };
    }

    pub fn dot(self: Vector, other: Vector) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn cross(self: Vector, other: Vector) Vector {
        return Vector{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn length(self: Vector) f64 {
        return std.math.sqrt(lengthSquared(self));
    }

    pub fn lengthSquared(self: Vector) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn nearZero(self: Vector) bool {
        const close = 1e-8;
        return (@abs(self.x) < close) and (@abs(self.y) < close) and (@abs(self.z) < close);
    }

    pub fn unitVector(self: Vector) Vector {
        return self.scale(1.0 / self.length());
    }

    pub fn randomUnitVector() Vector {
        while (true) {
            const p = randomBound(-1, 1);
            const lensq = p.lengthSquared();
            if (1e-160 < lensq and p.lengthSquared() <= 1) {
                return p.scale(1.0 / std.math.sqrt(lensq));
            }
        }
    }

    pub fn randomOnHemisphere(normal: Vector) Vector {
        const onUnitSphere = randomUnitVector();
        if (onUnitSphere.dot(normal) > 0.0) {
            return onUnitSphere;
        } else {
            return onUnitSphere.scale(-1);
        }
    }

    pub fn reflect(v: Vector, n: Vector) Vector {
        return v.sub(n.scale(2.0 * v.dot(n)));
    }

    pub fn print(self: Vector, writer: anytype) !void {
        try writer.print("{d} {d} {d}\n", .{
            self.x,
            self.y,
            self.z,
        });
    }

    pub fn printAsColor(self: Vector, writer: anytype) !void {
        const intensity = Interval{ .min = 0, .max = 0.999 };
        try writer.print("{d} {d} {d}\n", .{
            @as(u8, @intFromFloat(256 * intensity.clamp(linearToGamma(self.x)))),
            @as(u8, @intFromFloat(256 * intensity.clamp(linearToGamma(self.y)))),
            @as(u8, @intFromFloat(256 * intensity.clamp(linearToGamma(self.z)))),
        });
    }
};

fn randomF64(min: f64, max: f64) f64 {
    // Returns a random real in [min,max).
    return (max - min) * prng.random().float(f64) + min;
}

pub fn random() Vector {
    return Vector{
        .x = prng.random().float(f64),
        .y = prng.random().float(f64),
        .z = prng.random().float(f64),
    };
}

pub fn randomBound(min: f64, max: f64) Vector {
    return Vector{
        .x = randomF64(min, max),
        .y = randomF64(min, max),
        .z = randomF64(min, max),
    };
}

pub fn linearToGamma(linearComponent: f64) f64 {
    if (linearComponent > 0) return std.math.sqrt(linearComponent);
    return 0;
}
