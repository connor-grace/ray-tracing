const std = @import("std");

const Interval = @import("interval.zig").Interval;
const HitRecord = @import("hitrecord.zig").HitRecord;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;

pub const HitList = struct {
    list: std.ArrayList(Sphere),

    pub fn add(self: *HitList, object: Sphere) !void {
        try self.list.append(object);
    }

    pub fn hit(self: HitList, ray: Ray, interval: Interval, hitRecord: *HitRecord) bool {
        var tempHitRecord: HitRecord = undefined;
        var hitAnything = false;
        var closestSoFar = interval.max;

        for (self.list.items) |object| {
            const i = Interval{ .min = interval.min, .max = closestSoFar };
            if (object.hit(ray, i, &tempHitRecord)) {
                hitAnything = true;
                closestSoFar = tempHitRecord.t;
                hitRecord.* = tempHitRecord;
            }
        }

        return hitAnything;
    }
};
