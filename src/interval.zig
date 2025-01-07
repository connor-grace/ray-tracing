const std = @import("std");

pub const Interval = struct {
    min: f64 = std.math.inf(f64),
    max: f64 = -std.math.inf(f64),

    pub fn size(self: Interval) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }
};

pub const empty = Interval{};

pub const universe = Interval{
    .min = -std.math.inf(f64),
    .max = std.math.inf(f64),
};
