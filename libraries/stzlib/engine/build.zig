const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Shared library for Ring FFI
    const shared_mod = b.createModule(.{
        .root_source_file = b.path("src/engine.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const shared_lib = b.addLibrary(.{
        .name = "softanza_engine",
        .root_module = shared_mod,
        .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    // Static library for Zin direct linking
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

    // Tests
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
