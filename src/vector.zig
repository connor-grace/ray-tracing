const std = @import("std");

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

    pub fn scale(self: Vector, scalar: f64) Vector {
        return Vector{
            .x = self.x * scalar,
            .y = self.y * scalar,
            .z = self.z * scalar,
        };
    }

    pub fn length(self: Vector) f64 {
        return std.math.sqrt(lengthSquared(self));
    }

    pub fn lengthSquared(self: Vector) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn unitVector(self: Vector) Vector {
        return self.scale(1.0 / self.length());
    }

    pub fn print(self: Vector, writer: anytype) !void {
        try writer.print("{d} {d} {d}\n", .{
            self.x * 255,
            self.y * 255,
            self.z * 255,
        });
    }
};
