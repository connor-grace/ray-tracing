const std = @import("std");

const HitRecord = @import("hitrecord.zig").HitRecord;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;

pub const HitList = struct {
    list: std.ArrayList(Sphere),

    pub fn add(self: *HitList, object: Sphere) !void {
        try self.list.append(object);
    }

    pub fn hit(self: HitList, ray: Ray, rayTMin: f64, rayTMax: f64, hitRecord: *HitRecord) bool {
        var tempHitRecord: HitRecord = undefined;
        var hitAnything = false;
        var closestSoFar = rayTMax;

        for (self.list.items) |object| {
            if (object.hit(ray, rayTMin, closestSoFar, &tempHitRecord)) {
                hitAnything = true;
                closestSoFar = tempHitRecord.t;
                hitRecord.* = tempHitRecord;
            }
        }

        return hitAnything;
    }
};
