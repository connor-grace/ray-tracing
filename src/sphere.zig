const std = @import("std");

const HitRecord = @import("hitrecord.zig").HitRecord;
const Interval = @import("interval.zig").Interval;
const Material = @import("material.zig").Material;
const Ray = @import("ray.zig").Ray;
const Vector = @import("vector.zig").Vector;

pub const Sphere = struct {
    center: Vector,
    radius: f64,
    material: Material,

    pub fn init(center: Vector, radius: f64, material: Material) Sphere {
        return Sphere{
            .center = center,
            .radius = if (radius > 0) radius else 0,
            .material = material,
        };
    }

    pub fn hit(self: Sphere, ray: Ray, interval: Interval, hitRecord: *HitRecord) bool {
        const oc = self.center.sub(ray.origin);
        const a = ray.direction.lengthSquared();
        const h = ray.direction.dot(oc);
        const c = oc.lengthSquared() - self.radius * self.radius;

        const discriminant = h * h - a * c;
        if (discriminant < 0) {
            return false;
        }

        const sqrtd = std.math.sqrt(discriminant);
        var root = (h - sqrtd) / a;
        if (!interval.surrounds(root)) {
            root = (h + sqrtd) / a;
            if (!interval.surrounds(root)) {
                return false;
            }
        }

        hitRecord.t = root;
        hitRecord.point = ray.at(hitRecord.t);
        hitRecord.normal = hitRecord.point.sub(self.center).scale(1.0 / self.radius);
        hitRecord.setFaceNormal(ray, hitRecord.normal);
        hitRecord.material = self.material;

        return true;
    }
};
