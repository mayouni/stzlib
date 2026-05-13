// Softanza CLI -- single entry point for the Softanza development lifecycle

const std = @import("std");
const fs = std.fs;
const process = std.process;

pub fn main() !u8 {
    var gpa_impl: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa_impl.deinit();
    const gpa = gpa_impl.allocator();

    const args = try process.argsAlloc(gpa);
    defer process.argsFree(gpa, args);

    if (args.len < 2) {
        printUsage();
        return 0;
    }

    const cmd = args[1];

    if (std.mem.eql(u8, cmd, "version")) {
        return cmdVersion();
    } else if (std.mem.eql(u8, cmd, "doctor")) {
        return cmdDoctor(gpa);
    } else if (std.mem.eql(u8, cmd, "run")) {
        if (args.len < 3) {
            printErr("Usage: softanza run <file.ring>\n");
            return 1;
        }
        return cmdRun(gpa, args[2..]);
    } else if (std.mem.eql(u8, cmd, "test")) {
        const path = if (args.len >= 3) args[2] else null;
        return cmdTest(gpa, path);
    } else if (std.mem.eql(u8, cmd, "build")) {
        return cmdBuild(gpa);
    } else if (std.mem.eql(u8, cmd, "help") or std.mem.eql(u8, cmd, "--help") or std.mem.eql(u8, cmd, "-h")) {
        printUsage();
        return 0;
    } else {
        printErr("Unknown command: ");
        printErr(cmd);
        printErr("\n");
        printUsage();
        return 1;
    }
}

fn w() @TypeOf(fs.File.stdout().deprecatedWriter()) {
    return fs.File.stdout().deprecatedWriter();
}

fn printUsage() void {
    w().writeAll(
        \\Softanza -- the power of Zig, the beauty of Ring
        \\
        \\Usage: softanza <command> [args]
        \\
        \\Commands:
        \\  run <file.ring>     Run a Ring script with Softanza loaded
        \\  test [dir|file]     Run test files, report pass/fail
        \\  build               Build the Engine DLL
        \\  version             Show Engine + Ring versions
        \\  doctor              Check setup (Ring, Engine, paths)
        \\  help                Show this message
        \\
    ) catch {};
}

fn cmdVersion() u8 {
    w().writeAll(
        \\Softanza CLI    0.2.0
        \\Softanza Engine 0.2.0 (Zig)
        \\Tier 1: String + Unicode (20 + 6 functions)
        \\Tier 2: DateTime + File + Locale (35 + 17 + 10 functions)
        \\
    ) catch {};
    return 0;
}

fn cmdDoctor(gpa: std.mem.Allocator) u8 {
    const wr = w();
    var ok = true;

    wr.writeAll("Softanza Doctor\n---------------\n") catch {};

    const ring_result = process.Child.run(.{
        .allocator = gpa,
        .argv = &.{ "ring", "-version" },
    }) catch {
        wr.writeAll("[FAIL] Ring not found in PATH\n") catch {};
        ok = false;
        return checkEngine(wr, ok);
    };
    gpa.free(ring_result.stdout);
    gpa.free(ring_result.stderr);

    if (ring_result.term.Exited == 0) {
        wr.writeAll("[OK]   Ring found in PATH\n") catch {};
    } else {
        wr.writeAll("[FAIL] Ring returned error\n") catch {};
        ok = false;
    }

    return checkEngine(wr, ok);
}

fn checkEngine(wr: @TypeOf(w()), ok_in: bool) u8 {
    var ok = ok_in;
    const dll_path = "engine/zig-out/bin/softanza_engine.dll";
    fs.cwd().access(dll_path, .{}) catch {
        wr.writeAll("[FAIL] Engine DLL not found (run: softanza build)\n") catch {};
        ok = false;
        return if (ok) 0 else 1;
    };
    wr.writeAll("[OK]   Engine DLL found\n") catch {};
    return if (ok) 0 else 1;
}

fn cmdRun(gpa: std.mem.Allocator, args: []const []const u8) u8 {
    var argv: std.ArrayList([]const u8) = .{};
    defer argv.deinit(gpa);
    argv.append(gpa, "ring") catch return 1;
    for (args) |arg| {
        argv.append(gpa, arg) catch return 1;
    }

    var child = process.Child.init(argv.items, gpa);
    const term = child.spawnAndWait() catch {
        printErr("Failed to launch Ring\n");
        return 1;
    };

    return switch (term) {
        .Exited => |code| code,
        else => 1,
    };
}

fn cmdTest(gpa: std.mem.Allocator, path: ?[]const u8) u8 {
    const wr = w();
    _ = path;

    wr.writeAll("Softanza Test Runner\n====================\n") catch {};

    const test_dirs = [_][]const u8{ "base/test", "core/test" };
    var total: u32 = 0;
    var passed: u32 = 0;
    var failed: u32 = 0;

    for (test_dirs) |dir| {
        var d = fs.cwd().openDir(dir, .{ .iterate = true }) catch continue;
        defer d.close();
        var it = d.iterate();
        while (it.next() catch null) |entry| {
            if (entry.kind != .file) continue;
            const name = entry.name;
            if (!std.mem.endsWith(u8, name, ".ring")) continue;
            if (!containsIgnoreCase(name, "test")) continue;

            total += 1;
            const full_path = std.fmt.allocPrint(gpa, "{s}/{s}", .{ dir, name }) catch continue;
            defer gpa.free(full_path);

            const result = process.Child.run(.{
                .allocator = gpa,
                .argv = &.{ "ring", full_path },
            }) catch {
                wr.print("  FAIL  {s} (spawn error)\n", .{name}) catch {};
                failed += 1;
                continue;
            };
            gpa.free(result.stdout);
            gpa.free(result.stderr);

            if (result.term.Exited == 0) {
                wr.print("  PASS  {s}\n", .{name}) catch {};
                passed += 1;
            } else {
                wr.print("  FAIL  {s}\n", .{name}) catch {};
                failed += 1;
            }
        }
    }

    wr.print("\n{d} total, {d} passed, {d} failed\n", .{ total, passed, failed }) catch {};
    return if (failed > 0) 1 else 0;
}

fn cmdBuild(gpa: std.mem.Allocator) u8 {
    const wr = w();
    wr.writeAll("Building Softanza Engine...\n") catch {};

    const result = process.Child.run(.{
        .allocator = gpa,
        .argv = &.{ "zig", "build" },
        .cwd = "engine",
    }) catch {
        printErr("Failed to launch zig build\n");
        return 1;
    };
    gpa.free(result.stdout);
    gpa.free(result.stderr);

    if (result.term.Exited == 0) {
        wr.writeAll("Engine built successfully.\n") catch {};
        return 0;
    }
    printErr("Engine build failed.\n");
    return 1;
}

fn containsIgnoreCase(haystack: []const u8, needle: []const u8) bool {
    if (needle.len > haystack.len) return false;
    var i: usize = 0;
    while (i + needle.len <= haystack.len) : (i += 1) {
        var match = true;
        for (0..needle.len) |j| {
            if (std.ascii.toLower(haystack[i + j]) != std.ascii.toLower(needle[j])) {
                match = false;
                break;
            }
        }
        if (match) return true;
    }
    return false;
}

fn printErr(msg: []const u8) void {
    fs.File.stderr().deprecatedWriter().writeAll(msg) catch {};
}

test "containsIgnoreCase" {
    try std.testing.expect(containsIgnoreCase("stzStringTest.ring", "test"));
    try std.testing.expect(containsIgnoreCase("stzStringTest.ring", "Test"));
    try std.testing.expect(!containsIgnoreCase("stzString.ring", "test"));
}
