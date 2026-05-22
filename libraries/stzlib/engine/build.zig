const std = @import("std");

const Domain = struct {
    name: []const u8,
    entry: []const u8,
    needs_utf8proc: bool = false,
    needs_pcre2: bool = false,
    needs_ring: bool = false,
    needs_sqlite: bool = false,
};

// Core (stk_*): minimal, fast, constrained environments
const core_domains = [_]Domain{
    .{ .name = "stk_string", .entry = "src/stk_string_entry.zig", .needs_utf8proc = true, .needs_pcre2 = true, .needs_ring = true },
    .{ .name = "stk_datetime", .entry = "src/stk_datetime_entry.zig", .needs_ring = true },
    .{ .name = "stk_file", .entry = "src/stk_file_entry.zig", .needs_ring = true },
    .{ .name = "stk_locale", .entry = "src/stk_locale_entry.zig", .needs_ring = true },
};

// Base (stz_*): full features, superset of Core
const base_domains = [_]Domain{
    .{ .name = "stz_string", .entry = "src/stz_string_entry.zig", .needs_utf8proc = true, .needs_pcre2 = true, .needs_ring = true },
    .{ .name = "stz_datetime", .entry = "src/stz_datetime_entry.zig", .needs_ring = true },
    .{ .name = "stz_file", .entry = "src/stz_file_entry.zig", .needs_ring = true },
    .{ .name = "stz_locale", .entry = "src/stz_locale_entry.zig", .needs_ring = true },
    .{ .name = "stz_regex", .entry = "src/stz_regex_entry.zig", .needs_utf8proc = true, .needs_pcre2 = true, .needs_ring = true },
    .{ .name = "stz_bytes", .entry = "src/stz_bytes_entry.zig", .needs_ring = true },
    .{ .name = "stz_json", .entry = "src/stz_json_entry.zig", .needs_ring = true },
    .{ .name = "stz_url", .entry = "src/stz_url_entry.zig", .needs_ring = true },
    .{ .name = "stz_system", .entry = "src/stz_system_entry.zig", .needs_ring = true },
    .{ .name = "stz_unicode", .entry = "src/stz_unicode_entry.zig", .needs_utf8proc = true, .needs_ring = true },
    .{ .name = "stz_meta", .entry = "src/stz_meta_entry.zig", .needs_ring = true },
    .{ .name = "stz_value", .entry = "src/stz_value_entry.zig", .needs_ring = true },
    .{ .name = "stz_number", .entry = "src/stz_number_entry.zig", .needs_ring = true },
    .{ .name = "stz_list", .entry = "src/stz_list_entry.zig", .needs_ring = true },
    .{ .name = "stz_hashmap", .entry = "src/stz_hashmap_entry.zig", .needs_ring = true },
    .{ .name = "stz_unidata", .entry = "src/stz_unidata_entry.zig", .needs_sqlite = true, .needs_ring = true },
};

fn addUtf8proc(mod: *std.Build.Module, lib: *std.Build.Step.Compile, b: *std.Build) void {
    mod.addIncludePath(b.path("vendor/utf8proc"));
    lib.addCSourceFiles(.{
        .files = &.{"vendor/utf8proc/utf8proc.c"},
        .flags = &.{"-DUTF8PROC_STATIC"},
    });
}

fn addPcre2(mod: *std.Build.Module, lib: *std.Build.Step.Compile, b: *std.Build) void {
    const pcre2_dir = "vendor/pcre2/pcre2-10.47/src";
    mod.addIncludePath(b.path(pcre2_dir));
    const pcre2_flags = &[_][]const u8{
        "-DHAVE_CONFIG_H",
        "-DPCRE2_CODE_UNIT_WIDTH=8",
        "-DSUPPORT_PCRE2_8",
        "-DSUPPORT_UNICODE",
        "-DPCRE2_STATIC",
    };
    lib.addCSourceFiles(.{
        .files = &.{
            pcre2_dir ++ "/pcre2_auto_possess.c",
            pcre2_dir ++ "/pcre2_chartables.c",
            pcre2_dir ++ "/pcre2_chkdint.c",
            pcre2_dir ++ "/pcre2_compile.c",
            pcre2_dir ++ "/pcre2_compile_cgroup.c",
            pcre2_dir ++ "/pcre2_compile_class.c",
            pcre2_dir ++ "/pcre2_config.c",
            pcre2_dir ++ "/pcre2_context.c",
            pcre2_dir ++ "/pcre2_convert.c",
            pcre2_dir ++ "/pcre2_dfa_match.c",
            pcre2_dir ++ "/pcre2_error.c",
            pcre2_dir ++ "/pcre2_extuni.c",
            pcre2_dir ++ "/pcre2_find_bracket.c",
            pcre2_dir ++ "/pcre2_jit_compile.c",
            pcre2_dir ++ "/pcre2_maketables.c",
            pcre2_dir ++ "/pcre2_match.c",
            pcre2_dir ++ "/pcre2_match_data.c",
            pcre2_dir ++ "/pcre2_match_next.c",
            pcre2_dir ++ "/pcre2_newline.c",
            pcre2_dir ++ "/pcre2_ord2utf.c",
            pcre2_dir ++ "/pcre2_pattern_info.c",
            pcre2_dir ++ "/pcre2_script_run.c",
            pcre2_dir ++ "/pcre2_serialize.c",
            pcre2_dir ++ "/pcre2_string_utils.c",
            pcre2_dir ++ "/pcre2_study.c",
            pcre2_dir ++ "/pcre2_substitute.c",
            pcre2_dir ++ "/pcre2_substring.c",
            pcre2_dir ++ "/pcre2_tables.c",
            pcre2_dir ++ "/pcre2_ucd.c",
            pcre2_dir ++ "/pcre2_valid_utf.c",
            pcre2_dir ++ "/pcre2_xclass.c",
        },
        .flags = pcre2_flags,
    });
}

fn addRing(mod: *std.Build.Module, lib: *std.Build.Step.Compile) void {
    mod.addIncludePath(.{ .cwd_relative = "D:/Ring126/language/include" });
    lib.addLibraryPath(.{ .cwd_relative = "D:/Ring126/lib" });
    lib.linkSystemLibrary("ring");
}

fn addSqlite(mod: *std.Build.Module, lib: *std.Build.Step.Compile, b: *std.Build) void {
    mod.addIncludePath(b.path("vendor/sqlite"));
    lib.addCSourceFiles(.{
        .files = &.{"vendor/sqlite/sqlite3.c"},
        .flags = &.{
            "-DSQLITE_THREADSAFE=1",
            "-DSQLITE_OMIT_LOAD_EXTENSION",
            "-DSQLITE_DQS=0",
        },
    });
}

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
        if (dom.needs_utf8proc) addUtf8proc(mod, lib, b);
        if (dom.needs_pcre2) addPcre2(mod, lib, b);
        if (dom.needs_ring) addRing(mod, lib);
        if (dom.needs_sqlite) addSqlite(mod, lib, b);
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
        if (dom.needs_utf8proc) addUtf8proc(mod, lib, b);
        if (dom.needs_pcre2) addPcre2(mod, lib, b);
        if (dom.needs_ring) addRing(mod, lib);
        if (dom.needs_sqlite) addSqlite(mod, lib, b);
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
    addUtf8proc(static_mod, static_lib, b);
    addPcre2(static_mod, static_lib, b);
    addSqlite(static_mod, static_lib, b);
    b.installArtifact(static_lib);

    // Tests run through engine.zig (covers all modules)
    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/engine.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const tests = b.addTest(.{ .root_module = test_mod });
    addUtf8proc(test_mod, tests, b);
    addPcre2(test_mod, tests, b);
    addSqlite(test_mod, tests, b);
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run Softanza Engine tests");
    test_step.dependOn(&run_tests.step);
}
