const std = @import("std");
const pdf = @import("pdf");
pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const a = gpa.allocator();
    const args = try std.process.argsAlloc(a);
    defer std.process.argsFree(a, args);
    var outbuf: [4096]u8 = undefined;
    var w = std.fs.File.stdout().writer(&outbuf);
    const o = &w.interface;
    for (args[1..]) |path| {
        var t = std.time.Timer.start() catch unreachable;
        var r = pdf.readFile(a, path) catch |e| {
            try o.print("{s}: ERROR {s}\n", .{ path, @errorName(e) });
            continue;
        };
        defer r.deinit();
        try o.print("== {s}: pages {d} glyphs {d} blocks {d} in {d} us\n", .{ std.fs.path.basename(path), r.pages, r.glyphs, r.blocks.len, t.read() / 1000 });
        for (r.blocks) |b| {
            try o.print("p{d} {s}/{d} [{d:.0},{d:.0},{d:.0},{d:.0}] {d:.1}{s}{s} | {s}\n", .{ b.page, pdf.kindName(b.kind), b.level, b.x0, b.y0, b.x1, b.y1, b.size, if (b.bold) " B" else "", if (b.mono) " M" else "", b.text });
            for (b.rows) |row| {
                try o.writeAll("      ");
                for (row) |c| try o.print("[{s}] ", .{c});
                try o.writeAll("\n");
            }
        }
    }
    try o.flush();
}
