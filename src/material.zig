const HitRecord = @import("hitrecord.zig").HitRecord;
const Ray = @import("ray.zig").Ray;
const Vector = @import("vector.zig").Vector;

pub const Material = struct {
    albedo: Vector,
    type: Type,

    pub fn lambertianScatter(
        self: Material,
        hitRecord: HitRecord,
        attenuation: *Vector,
        scattered: *Ray,
    ) bool {
        var scatterDirection = hitRecord.normal.add(Vector.randomUnitVector());
        if (scatterDirection.nearZero()) scatterDirection = hitRecord.normal;
        scattered.* = Ray{ .origin = hitRecord.point, .direction = scatterDirection };
        attenuation.* = self.albedo;
        return true;
    }

    pub fn metalScatter(
        self: Material,
        rayIn: Ray,
        hitRecord: HitRecord,
        attenuation: *Vector,
        scattered: *Ray,
    ) bool {
        const reflected = Vector.reflect(rayIn.direction, hitRecord.normal);
        scattered.* = Ray{ .origin = hitRecord.point, .direction = reflected };
        attenuation.* = self.albedo;
        return true;
    }
};

pub const Type = enum {
    lambertian,
    metal,
};
