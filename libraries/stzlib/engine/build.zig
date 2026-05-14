const std = @import("std");

const Domain = struct {
    name: []const u8,
    entry: []const u8,
};

// Core (stk_*): minimal, fast, constrained environments
const core_domains = [_]Domain{
    .{ .name = "stk_string", .entry = "src/stk_string_entry.zig" },
    .{ .name = "stk_datetime", .entry = "src/stk_datetime_entry.zig" },
    .{ .name = "stk_file", .entry = "src/stk_file_entry.zig" },
    .{ .name = "stk_locale", .entry = "src/stk_locale_entry.zig" },
};

// Base (stz_*): full features, superset of Core
const base_domains = [_]Domain{
    .{ .name = "stz_string", .entry = "src/stz_string_entry.zig" },
    .{ .name = "stz_datetime", .entry = "src/stz_datetime_entry.zig" },
    .{ .name = "stz_file", .entry = "src/stz_file_entry.zig" },
    .{ .name = "stz_locale", .entry = "src/stz_locale_entry.zig" },
    .{ .name = "stz_regex", .entry = "src/stz_regex_entry.zig" },
    .{ .name = "stz_bytes", .entry = "src/stz_bytes_entry.zig" },
    .{ .name = "stz_json", .entry = "src/stz_json_entry.zig" },
    .{ .name = "stz_url", .entry = "src/stz_url_entry.zig" },
    .{ .name = "stz_system", .entry = "src/stz_system_entry.zig" },
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Core layer DLLs
    for (core_domains) |dom| {
        const mod = b.createModule(.{
            .root_source_file = b.path(dom.entry),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        const lib = b.addLibrary(.{
            .name = @constCast(dom.name),
            .root_module = mod,
            .linkage = .dynamic,
        });
        b.installArtifact(lib);
    }

    // Base layer DLLs
    for (base_domains) |dom| {
        const mod = b.createModule(.{
            .root_source_file = b.path(dom.entry),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        const lib = b.addLibrary(.{
            .name = @constCast(dom.name),
            .root_module = mod,
            .linkage = .dynamic,
        });
        b.installArtifact(lib);
    }

    // Static library linking everything (for Zin direct linking / CLI)
    const static_mod = b.createModule(.{
        .root_source_file = b.path("src/engine.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const static_lib = b.addLibrary(.{
        .name = "softanza_engine_static",
        .root_module = static_mod,
        .linkage = .static,
    });
    b.installArtifact(static_lib);

    // Tests run through engine.zig (covers all modules)
    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/engine.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run Softanza Engine tests");
    test_step.dependOn(&run_tests.step);
}
