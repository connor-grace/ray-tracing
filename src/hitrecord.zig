const Material = @import("material.zig").Material;
const Ray = @import("ray.zig").Ray;
const Vector = @import("vector.zig").Vector;

pub const HitRecord = struct {
    point: Vector,
    normal: Vector,
    material: Material,
    t: f64,
    frontFace: bool,

    pub fn setFaceNormal(self: *HitRecord, ray: Ray, outwardNormal: Vector) void {
        self.frontFace = ray.direction.dot(outwardNormal) < 0;
        self.normal = if (self.frontFace) outwardNormal else outwardNormal.scale(-1);
    }
};
