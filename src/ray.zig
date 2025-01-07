const Vector = @import("vector.zig").Vector;

pub const Ray = struct {
    origin: Vector,
    direction: Vector,

    pub fn at(self: Ray, t: f64) Vector {
        return self.origin.add(self.direction.scale(t));
    }
};
