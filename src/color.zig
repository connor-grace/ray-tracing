pub const Color = struct {
    r: f64,
    b: f64,
    g: f64,

    pub fn add(self: Color, other: Color) Color {
        return Color{
            .r = self.r + other.r,
            .b = self.b + other.b,
            .g = self.g + other.g,
        };
    }

    pub fn scale(self: Color, scalar: f64) Color {
        return Color{
            .r = self.r * scalar,
            .b = self.b * scalar,
            .g = self.g * scalar,
        };
    }

    pub fn print(self: Color, writer: anytype) !void {
        try writer.print("{d} {d} {d}\n", .{
            @as(u8, @intFromFloat(self.r * 255.999)),
            @as(u8, @intFromFloat(self.b * 255.999)),
            @as(u8, @intFromFloat(self.g * 255.999)),
        });
    }
};
