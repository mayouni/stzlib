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
    .{ .name = "stz_table", .entry = "src/stz_table_entry.zig", .needs_ring = true },
    .{ .name = "stz_matrix", .entry = "src/stz_matrix_entry.zig", .needs_ring = true },
    .{ .name = "stz_random", .entry = "src/stz_random_entry.zig", .needs_ring = true },
    .{ .name = "stz_csv", .entry = "src/stz_csv_entry.zig", .needs_ring = true },
    .{ .name = "stz_stats", .entry = "src/stz_stats_entry.zig", .needs_ring = true },
    .{ .name = "stz_graph", .entry = "src/stz_graph_entry.zig", .needs_ring = true },
    .{ .name = "stz_text", .entry = "src/stz_text_entry.zig", .needs_ring = true },
    .{ .name = "stz_yielder", .entry = "src/stz_yielder_entry.zig", .needs_ring = true },
    .{ .name = "stz_uuid", .entry = "src/stz_uuid_entry.zig", .needs_ring = true },
    .{ .name = "stz_codec", .entry = "src/stz_codec_entry.zig", .needs_ring = true },
    .{ .name = "stz_bits", .entry = "src/stz_bits_entry.zig", .needs_ring = true },
    .{ .name = "stz_html", .entry = "src/stz_html_entry.zig", .needs_ring = true },
    .{ .name = "stz_geo", .entry = "src/stz_geo_entry.zig", .needs_ring = true },
    .{ .name = "stz_compress", .entry = "src/stz_compress_entry.zig", .needs_ring = true },
    .{ .name = "stz_solver", .entry = "src/stz_solver_entry.zig", .needs_ring = true },
    .{ .name = "stz_watch", .entry = "src/stz_watch_entry.zig", .needs_ring = true },
    .{ .name = "stz_log", .entry = "src/stz_log_entry.zig", .needs_ring = true },
    .{ .name = "stz_cache", .entry = "src/stz_cache_entry.zig", .needs_ring = true },
    .{ .name = "stz_stream", .entry = "src/stz_stream_entry.zig", .needs_ring = true },
    .{ .name = "stz_process", .entry = "src/stz_process_entry.zig", .needs_ring = true },
    .{ .name = "stz_arith", .entry = "src/stz_arith_entry.zig", .needs_ring = true },
    .{ .name = "stz_registry", .entry = "src/stz_registry_entry.zig", .needs_ring = true },
    .{ .name = "stz_profiler", .entry = "src/stz_profiler_entry.zig", .needs_ring = true },
    .{ .name = "stz_callstack", .entry = "src/stz_callstack_entry.zig", .needs_ring = true },
    .{ .name = "stz_crypto", .entry = "src/stz_crypto_entry.zig", .needs_ring = true },
    .{ .name = "stz_async", .entry = "src/stz_async_entry.zig", .needs_ring = true },
    .{ .name = "stz_embed", .entry = "src/stz_embed_entry.zig", .needs_ring = true },
    .{ .name = "stz_smallfn", .entry = "src/stz_smallfn_entry.zig", .needs_ring = true },
    .{ .name = "stz_execmodel", .entry = "src/stz_execmodel_entry.zig", .needs_ring = true },
    .{ .name = "stz_numtheory", .entry = "src/stz_numtheory_entry.zig", .needs_ring = true },
    .{ .name = "stz_splitter", .entry = "src/stz_splitter_entry.zig", .needs_ring = true },
    .{ .name = "stz_univops", .entry = "src/stz_univops_entry.zig", .needs_ring = true },
    .{ .name = "stz_pattern", .entry = "src/stz_pattern_entry.zig", .needs_ring = true },
    .{ .name = "stz_stringart", .entry = "src/stz_stringart_entry.zig", .needs_ring = true },
    .{ .name = "stz_display", .entry = "src/stz_display_entry.zig", .needs_ring = true },
    .{ .name = "stz_constraint", .entry = "src/stz_constraint_entry.zig", .needs_ring = true },
    .{ .name = "stz_natlang", .entry = "src/stz_natlang_entry.zig", .needs_ring = true },
    .{ .name = "stz_ccode", .entry = "src/stz_ccode_entry.zig", .needs_ring = true },
    .{ .name = "stz_reactive", .entry = "src/stz_reactive_entry.zig", .needs_ring = true },
    .{ .name = "stz_knowgraph", .entry = "src/stz_knowgraph_entry.zig", .needs_ring = true },
    .{ .name = "stz_namedvars", .entry = "src/stz_namedvars_entry.zig", .needs_ring = true },
    .{ .name = "stz_truth", .entry = "src/stz_truth_entry.zig", .needs_ring = true },
    .{ .name = "stz_quantifier", .entry = "src/stz_quantifier_entry.zig", .needs_ring = true },
    .{ .name = "stz_adverb", .entry = "src/stz_adverb_entry.zig", .needs_ring = true },
    .{ .name = "stz_timeline", .entry = "src/stz_timeline_entry.zig", .needs_ring = true },
    .{ .name = "stz_gridnav", .entry = "src/stz_gridnav_entry.zig", .needs_ring = true },
    .{ .name = "stz_sectmerge", .entry = "src/stz_sectmerge_entry.zig", .needs_ring = true },
    .{ .name = "stz_deepops", .entry = "src/stz_deepops_entry.zig", .needs_ring = true },
    .{ .name = "stz_reaxis", .entry = "src/stz_reaxis_entry.zig", .needs_ring = true },
    .{ .name = "stz_softanzuter", .entry = "src/stz_softanzuter_entry.zig", .needs_ring = true },
    .{ .name = "stz_polyglot", .entry = "src/stz_polyglot_entry.zig", .needs_ring = true },
    .{ .name = "stz_polycode", .entry = "src/stz_polycode_entry.zig", .needs_ring = true },
    .{ .name = "stz_provenance", .entry = "src/stz_provenance_entry.zig", .needs_ring = true },
    .{ .name = "stz_confidence", .entry = "src/stz_confidence_entry.zig", .needs_ring = true },
    .{ .name = "stz_explain", .entry = "src/stz_explain_entry.zig", .needs_ring = true },
    .{ .name = "stz_similarity", .entry = "src/stz_similarity_entry.zig", .needs_ring = true },
    .{ .name = "stz_context", .entry = "src/stz_context_entry.zig", .needs_ring = true },
    .{ .name = "stz_resource", .entry = "src/stz_resource_entry.zig", .needs_ring = true },
    .{ .name = "stz_validator", .entry = "src/stz_validator_entry.zig", .needs_ring = true },
    .{ .name = "stz_schema", .entry = "src/stz_schema_entry.zig", .needs_ring = true },
    .{ .name = "stz_intent", .entry = "src/stz_intent_entry.zig", .needs_ring = true },
    .{ .name = "stz_embedding", .entry = "src/stz_embedding_entry.zig", .needs_ring = true },
    .{ .name = "stz_sequence", .entry = "src/stz_sequence_entry.zig", .needs_ring = true },
    .{ .name = "stz_topology", .entry = "src/stz_topology_entry.zig", .needs_ring = true },
    .{ .name = "stz_relations", .entry = "src/stz_relations_entry.zig", .needs_ring = true },
    .{ .name = "stz_statemachine", .entry = "src/stz_statemachine_entry.zig", .needs_ring = true },
    .{ .name = "stz_interact", .entry = "src/stz_interact_entry.zig", .needs_ring = true },
    .{ .name = "stz_skill", .entry = "src/stz_skill_entry.zig", .needs_ring = true },
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

    // Generator: populate reference data tables into unicode.db
    const gen_refdata_mod = b.createModule(.{
        .root_source_file = b.path("tools/gen_refdata.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const gen_refdata = b.addExecutable(.{
        .name = "gen_refdata",
        .root_module = gen_refdata_mod,
    });
    addSqlite(gen_refdata_mod, gen_refdata, b);
    b.installArtifact(gen_refdata);
    const gen_refdata_step = b.step("gen-refdata", "Generate per-class reference databases");
    const gen_refdata_run = b.addRunArtifact(gen_refdata);
    gen_refdata_run.setCwd(b.path("."));
    gen_refdata_step.dependOn(&gen_refdata_run.step);

    // Tool: clean reference tables from unicode.db (one-time migration)
    const clean_mod = b.createModule(.{
        .root_source_file = b.path("tools/clean_unicode_db.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const clean_exe = b.addExecutable(.{
        .name = "clean_unicode_db",
        .root_module = clean_mod,
    });
    addSqlite(clean_mod, clean_exe, b);
    const clean_step = b.step("clean-unicode-db", "Remove reference tables from unicode.db");
    const clean_run = b.addRunArtifact(clean_exe);
    clean_run.setCwd(b.path("."));
    clean_step.dependOn(&clean_run.step);
}
