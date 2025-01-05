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

    pub fn unitVector(self: Vector) Vector {
        return self.scale(1.0 / self.length());
    }

    pub fn print(self: Vector, writer: anytype) !void {
        try writer.print("{d} {d} {d}\n", .{
            self.x,
            self.y,
            self.z,
        });
    }
};
