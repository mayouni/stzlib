// Softanza CLI -- single entry point for the Softanza development lifecycle

const std = @import("std");
const fs = std.fs;
const process = std.process;
const engine_status = @import("engine_status.zig");

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
    } else if (std.mem.eql(u8, cmd, "status")) {
        return cmdStatus();
    } else if (std.mem.eql(u8, cmd, "coverage")) {
        const filter = if (args.len >= 3) args[2] else null;
        return cmdCoverage(filter);
    } else if (std.mem.eql(u8, cmd, "roadmap")) {
        return cmdRoadmap();
    } else if (std.mem.eql(u8, cmd, "next")) {
        return cmdNext();
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
        \\
        \\  status              Engine progress overview (domains + counts)
        \\  coverage [domain]   Per-domain delegation breakdown
        \\  roadmap             Engine milestones (DONE / WIP / PLAN)
        \\  next                Next-priority work to land
        \\
        \\  help                Show this message
        \\
    ) catch {};
}

fn cmdVersion() u8 {
    w().writeAll(
        \\Softanza CLI    0.3.0
        \\Softanza Engine 0.3.0 (Zig, modular, layered)
        \\
        \\Core (stk_*) -- minimal, fast, constrained:
        \\  stk_string   12 funcs   stk_datetime 24 funcs
        \\  stk_file      6 funcs   stk_locale    2 funcs
        \\
        \\Base (stz_*) -- full features, superset of Core:
        \\  stz_string   26 funcs   stz_datetime 50 funcs
        \\  stz_file     17 funcs   stz_locale   10 funcs
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
    const domains = [_][]const u8{ "string", "datetime", "file", "locale" };
    const layers = [_][]const u8{ "stk", "stz" };
    for (layers) |layer| {
        for (domains) |domain| {
            var path_buf: [128]u8 = undefined;
            const dll_path = std.fmt.bufPrint(&path_buf, "engine/zig-out/bin/{s}_{s}.dll", .{ layer, domain }) catch continue;
            fs.cwd().access(dll_path, .{}) catch {
                wr.print("[FAIL] {s}_{s}.dll not found\n", .{ layer, domain }) catch {};
                ok = false;
                continue;
            };
            wr.print("[OK]   {s}_{s}.dll\n", .{ layer, domain }) catch {};
        }
    }
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

fn cmdStatus() u8 {
    const wr = w();
    const m = engine_status.macro;
    wr.writeAll("Softanza Engine Status\n======================\n\n") catch {};

    wr.writeAll("Macro (canonical, from SOFTANZA_ENGINE_MACROPLAN.md):\n") catch {};
    wr.print("  modules designed     {d}\n", .{m.modules_designed}) catch {};
    wr.print("  modules built        {d}\n", .{m.modules_built}) catch {};
    wr.print("  design principles    {d}\n", .{m.design_principles}) catch {};
    wr.print("  engine tests         {d} passing\n", .{m.engine_tests}) catch {};
    wr.print("  DLLs shipping        {d}\n", .{m.dlls_shipping}) catch {};
    wr.print("  Qt dependencies      {d} (fully purged)\n", .{m.qt_dependencies}) catch {};
    wr.print("  Ring bridge regs     {d} DLL functions\n", .{m.ring_bridge_regs}) catch {};
    wr.print("  Ring classes bridged {d} files, {d}+ engine calls\n", .{ m.ring_classes_bridged, m.ring_engine_calls }) catch {};
    wr.print("  last updated         {s} (session {d})\n", .{ m.last_updated, m.last_session }) catch {};
    wr.writeAll("\n") catch {};

    var d_done: u32 = 0;
    var d_wip: u32 = 0;
    var d_plan: u32 = 0;
    var d_part: u32 = 0;
    var fns_total: u32 = 0;
    var bridged_total: u32 = 0;
    for (engine_status.domains) |d| {
        switch (d.status) {
            .done => d_done += 1,
            .in_progress => d_wip += 1,
            .planned => d_plan += 1,
            .partial => d_part += 1,
        }
        fns_total += d.engine_fns;
        bridged_total += d.ring_methods_bridged;
    }

    var sub_clean: u32 = 0;
    var sub_dirty: u32 = 0;
    var sub_methods: u32 = 0;
    var sub_backed: u32 = 0;
    for (engine_status.submodules) |s| {
        if (s.scoping_clean) sub_clean += 1 else sub_dirty += 1;
        sub_methods += s.methods;
        sub_backed += s.engine_backed;
    }

    var me_done: u32 = 0;
    var me_wip: u32 = 0;
    var me_part: u32 = 0;
    var me_plan: u32 = 0;
    var ms_done: u32 = 0;
    var ms_wip: u32 = 0;
    var ms_part: u32 = 0;
    var ms_plan: u32 = 0;
    for (engine_status.milestones) |ms| {
        const is_engine = std.mem.eql(u8, ms.track, "engine");
        switch (ms.status) {
            .done => if (is_engine) {
                me_done += 1;
            } else {
                ms_done += 1;
            },
            .in_progress => if (is_engine) {
                me_wip += 1;
            } else {
                ms_wip += 1;
            },
            .partial => if (is_engine) {
                me_part += 1;
            } else {
                ms_part += 1;
            },
            .planned => if (is_engine) {
                me_plan += 1;
            } else {
                ms_plan += 1;
            },
        }
    }

    wr.writeAll("Tracked here (subset of full 87-DLL surface):\n") catch {};
    wr.print("  Domains    {d} ({d} DONE, {d} WIP, {d} PLAN, {d} PART)\n", .{ engine_status.domains.len, d_done, d_wip, d_plan, d_part }) catch {};
    wr.print("             ~{d} engine fns / ~{d} ring methods bridged\n", .{ fns_total, bridged_total }) catch {};
    wr.writeAll("\n") catch {};
    wr.print("  Submodules {d} list-domain ({d} scoping-clean, {d} debt)\n", .{ engine_status.submodules.len, sub_clean, sub_dirty }) catch {};
    wr.print("             ~{d} methods, ~{d} engine-backed ({d}%)\n", .{
        sub_methods,
        sub_backed,
        if (sub_methods == 0) 0 else sub_backed * 100 / sub_methods,
    }) catch {};
    wr.writeAll("\n") catch {};
    wr.print("  M-E track  {d} milestones ({d} DONE, {d} PART, {d} WIP, {d} PLAN)\n", .{ me_done + me_part + me_wip + me_plan, me_done, me_part, me_wip, me_plan }) catch {};
    wr.print("  M-S track  {d} milestones ({d} DONE, {d} PART, {d} WIP, {d} PLAN)\n", .{ ms_done + ms_part + ms_wip + ms_plan, ms_done, ms_part, ms_wip, ms_plan }) catch {};
    wr.writeAll("\nUse `softanza coverage` for per-domain detail,\n") catch {};
    wr.writeAll("    `softanza roadmap`  for milestones (M-E + M-S),\n") catch {};
    wr.writeAll("    `softanza next`     for the priority queue.\n") catch {};
    return 0;
}

fn cmdCoverage(filter: ?[]const u8) u8 {
    const wr = w();

    if (filter) |needle| {
        wr.print("Softanza Coverage -- domain: {s}\n", .{needle}) catch {};
        wr.writeAll("================================\n\n") catch {};

        var found = false;
        for (engine_status.domains) |d| {
            if (std.mem.eql(u8, d.name, needle)) {
                found = true;
                wr.print("[{s}] {s}\n", .{ d.status.tag(), d.name }) catch {};
                wr.print("  engine_module : {s}\n", .{d.engine_module}) catch {};
                wr.print("  ring_class    : {s}\n", .{d.ring_class}) catch {};
                wr.print("  bridge        : {s}\n", .{d.bridge}) catch {};
                wr.print("  engine fns    : {d}\n", .{d.engine_fns}) catch {};
                wr.print("  ring methods  : {d}\n", .{d.ring_methods_bridged}) catch {};
                wr.print("  notes         : {s}\n", .{d.notes}) catch {};
                break;
            }
        }
        if (!found) {
            wr.print("Domain '{s}' not tracked.\n", .{needle}) catch {};
            return 1;
        }

        // Show submodules belonging to this domain
        var any_sub = false;
        for (engine_status.submodules) |s| {
            if (std.mem.eql(u8, s.parent, needle)) {
                if (!any_sub) {
                    wr.writeAll("\nSubmodules:\n") catch {};
                    wr.writeAll("  scope  engine /total  name                            notes\n") catch {};
                    any_sub = true;
                }
                const scope_tag: []const u8 = if (s.scoping_clean) "clean" else "DEBT ";
                wr.print("  {s}  {d:>3} /{d:>4}    {s:<32}{s}\n", .{
                    scope_tag, s.engine_backed, s.methods, s.name, s.notes,
                }) catch {};
            }
        }
        return 0;
    }

    wr.writeAll("Softanza Coverage -- all domains\n") catch {};
    wr.writeAll("================================\n\n") catch {};
    wr.writeAll("status  engine /bridged  name        notes\n") catch {};
    for (engine_status.domains) |d| {
        wr.print("[{s}]  {d:>4}   /{d:>4}     {s:<11} {s}\n", .{
            d.status.tag(), d.engine_fns, d.ring_methods_bridged, d.name, d.notes,
        }) catch {};
    }
    wr.writeAll("\nRun `softanza coverage <domain>` to see submodules.\n") catch {};
    return 0;
}

fn cmdRoadmap() u8 {
    const wr = w();
    wr.writeAll("Softanza Roadmap\n================\n") catch {};
    wr.writeAll("Mirrors base/doc/design/SOFTANZA_ENGINE_MACROPLAN.md\n\n") catch {};

    wr.writeAll("ENGINE TRACK (M-E -- Zig modules, C ABI, Ring bridges)\n") catch {};
    wr.writeAll("------------------------------------------------------\n") catch {};
    for (engine_status.milestones) |m| {
        if (!std.mem.eql(u8, m.track, "engine")) continue;
        wr.print("[{s}] {s:<6}  {s}\n", .{ m.status.tag(), m.id, m.title }) catch {};
        wr.print("           {s}\n\n", .{m.summary}) catch {};
    }

    wr.writeAll("STZLIB TRACK (M-S -- Ring-side modularization, tests, docs)\n") catch {};
    wr.writeAll("-----------------------------------------------------------\n") catch {};
    for (engine_status.milestones) |m| {
        if (!std.mem.eql(u8, m.track, "stzlib")) continue;
        wr.print("[{s}] {s:<6}  {s}\n", .{ m.status.tag(), m.id, m.title }) catch {};
        wr.print("           {s}\n\n", .{m.summary}) catch {};
    }
    return 0;
}

fn cmdNext() u8 {
    const wr = w();
    wr.writeAll("Next-priority work\n==================\n\n") catch {};

    // 1. Partial milestones first (the active fronts that need closing)
    wr.writeAll("Partial / WIP milestones (active fronts):\n") catch {};
    var any_active = false;
    for (engine_status.milestones) |m| {
        if (m.status == .partial or m.status == .in_progress) {
            wr.print("  [{s}] {s:<6} ({s})  {s}\n", .{ m.status.tag(), m.id, m.track, m.title }) catch {};
            wr.print("                {s}\n", .{m.summary}) catch {};
            any_active = true;
        }
    }
    if (!any_active) wr.writeAll("  (none)\n") catch {};

    // 2. Scoping debt (the M-S1 phase 2 queue)
    wr.writeAll("\nScoping debt (M-S1 Phase 2 queue):\n") catch {};
    var any_debt = false;
    for (engine_status.submodules) |s| {
        if (!s.scoping_clean) {
            wr.print("  - {s:<28} ({d:>3} methods, {d} engine-backed)\n", .{
                s.name, s.methods, s.engine_backed,
            }) catch {};
            any_debt = true;
        }
    }
    if (!any_debt) wr.writeAll("  (none -- all submodules clean)\n") catch {};

    // 3. Planned milestones
    wr.writeAll("\nPlanned milestones:\n") catch {};
    var any_plan = false;
    for (engine_status.milestones) |m| {
        if (m.status == .planned) {
            wr.print("  [{s}] {s:<6} ({s})  {s}\n", .{ m.status.tag(), m.id, m.track, m.title }) catch {};
            any_plan = true;
        }
    }
    if (!any_plan) wr.writeAll("  (none)\n") catch {};

    return 0;
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
