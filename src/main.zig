const std = @import("std");

// Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
const dbg = std.debug.print;

pub fn main() !void {
    const imageWidth = 256;
    const imageHeight = 256;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{d} {d}\n255\n", .{ imageWidth, imageHeight });

    for (0..imageHeight) |y| {
        dbg("Lines remaining: {d}\n", .{imageHeight - y});
        for (0..imageWidth) |x| {
            const fx: f64 = @floatFromInt(x);
            const fy: f64 = @floatFromInt(y);
            const r: f64 = fx / (@as(f64, imageWidth - 1));
            const g: f64 = fy / (@as(f64, imageHeight - 1));
            const b: f64 = 0.0;

            const ir: u8 = @intFromFloat(r * 255);
            const ig: u8 = @intFromFloat(g * 255);
            const ib: u8 = @intFromFloat(b * 255);

            try stdout.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }
    }
    dbg("Done.\n", .{});

    try bw.flush();
}
