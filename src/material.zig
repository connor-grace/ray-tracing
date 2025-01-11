const std = @import("std");

const HitRecord = @import("hitrecord.zig").HitRecord;
const Ray = @import("ray.zig").Ray;
const Vector = @import("vector.zig").Vector;

var prng = std.rand.DefaultPrng.init(0);

pub const Material = struct {
    type: Type,
    albedo: Vector = undefined,
    fuzz: f64 = undefined,
    refractionIndex: f64 = undefined,

    pub fn scatter(
        self: Material,
        rayIn: Ray,
        hitRecord: HitRecord,
        attenuation: *Vector,
        scattered: *Ray,
    ) bool {
        return switch (self.type) {
            Type.lambertian => self.lambertianScatter(
                hitRecord,
                attenuation,
                scattered,
            ),
            Type.metal => self.metalScatter(
                rayIn,
                hitRecord,
                attenuation,
                scattered,
            ),
            Type.dialectric => self.dialectricScatter(
                rayIn,
                hitRecord,
                attenuation,
                scattered,
            ),
        };
    }

    fn lambertianScatter(
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

    fn metalScatter(
        self: Material,
        rayIn: Ray,
        hitRecord: HitRecord,
        attenuation: *Vector,
        scattered: *Ray,
    ) bool {
        const reflected = Vector.reflect(rayIn.direction, hitRecord.normal);
        const fuzz = if (self.fuzz < 1) self.fuzz else 1;
        const reflectedFuzz = reflected.unitVector()
            .add(Vector.randomUnitVector()
            .scale(fuzz));
        scattered.* = Ray{ .origin = hitRecord.point, .direction = reflectedFuzz };
        attenuation.* = self.albedo;
        return scattered.direction.dot(hitRecord.normal) > 0;
    }

    fn dialectricScatter(
        self: Material,
        rayIn: Ray,
        hitRecord: HitRecord,
        attenuation: *Vector,
        scattered: *Ray,
    ) bool {
        attenuation.* = Vector{ .x = 1, .y = 1, .z = 1 };
        const ri = if (hitRecord.frontFace) 1.0 / self.refractionIndex else self.refractionIndex;

        const unitDirection = rayIn.direction.unitVector();
        const cosTheta = @min(unitDirection.scale(-1).dot(hitRecord.normal), 1.0);
        const sinTheta = @sqrt(1.0 - cosTheta * cosTheta);

        const cannotRefract = ri * sinTheta > 1.0;
        const direction: Vector = if (cannotRefract or reflectance(cosTheta, ri) > prng.random().float(f64))
            Vector.reflect(unitDirection, hitRecord.normal)
        else
            Vector.refract(unitDirection, hitRecord.normal, ri);

        scattered.* = Ray{ .origin = hitRecord.point, .direction = direction };
        return true;
    }
};

pub const Type = enum {
    lambertian,
    metal,
    dialectric,
};

fn reflectance(cosine: f64, refractionIndex: f64) f64 {
    // Schlick's approximation
    var r0 = (1.0 - refractionIndex) / (1.0 + refractionIndex);
    r0 = r0 * r0;
    return r0 + (1.0 - r0) * std.math.pow(f64, (1.0 - cosine), 5);
}
