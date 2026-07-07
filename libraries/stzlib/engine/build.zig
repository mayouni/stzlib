const std = @import("std");
const builtin = @import("builtin");

const Domain = struct {
    name: []const u8,
    entry: []const u8,
    needs_utf8proc: bool = false,
    needs_pcre2: bool = false,
    needs_snowball: bool = false,
    needs_ring: bool = false,
    needs_sqlite: bool = false,
    needs_libuv: bool = false,
    needs_libcurl: bool = false,
    needs_ggml: bool = false,
};

// Core (stk_*): minimal, fast, constrained environments
const core_domains = [_]Domain{
    .{ .name = "stk_string", .entry = "src/stk_string_entry.zig", .needs_utf8proc = true, .needs_pcre2 = true, .needs_snowball = true, .needs_ring = true },
    .{ .name = "stk_datetime", .entry = "src/stk_datetime_entry.zig", .needs_ring = true },
    .{ .name = "stk_file", .entry = "src/stk_file_entry.zig", .needs_ring = true },
    .{ .name = "stk_locale", .entry = "src/stk_locale_entry.zig", .needs_ring = true },
};

// Base (stz_*): full features, superset of Core
const base_domains = [_]Domain{
    .{ .name = "stz_string", .entry = "src/stz_string_entry.zig", .needs_utf8proc = true, .needs_pcre2 = true, .needs_snowball = true, .needs_ring = true },
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
    .{ .name = "stz_list", .entry = "src/stz_list_entry.zig", .needs_utf8proc = true, .needs_ring = true },
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
    .{ .name = "stz_http", .entry = "src/stz_http_entry.zig", .needs_ring = true, .needs_libcurl = true },
    .{ .name = "stz_tcp", .entry = "src/stz_tcp_entry.zig", .needs_ring = true },
    .{ .name = "stz_fswatch", .entry = "src/stz_fswatch_entry.zig", .needs_ring = true },
    .{ .name = "stz_time", .entry = "src/stz_time_entry.zig", .needs_ring = true },
    .{ .name = "stz_pool", .entry = "src/stz_pool_entry.zig", .needs_ring = true },
    .{ .name = "stz_resilience", .entry = "src/stz_resilience_entry.zig", .needs_ring = true },
    .{ .name = "stz_histogram", .entry = "src/stz_histogram_entry.zig", .needs_ring = true },
    .{ .name = "stz_reactor", .entry = "src/stz_reactor_entry.zig", .needs_ring = true, .needs_libuv = true },
    .{ .name = "stz_tracectx", .entry = "src/stz_tracectx_entry.zig", .needs_ring = true },
    .{ .name = "stz_testsrv", .entry = "src/stz_testsrv_entry.zig", .needs_ring = true },
    .{ .name = "stz_geo", .entry = "src/stz_geo_entry.zig", .needs_ring = true },
    .{ .name = "stz_compress", .entry = "src/stz_compress_entry.zig", .needs_ring = true },
    .{ .name = "stz_solver", .entry = "src/stz_solver_entry.zig", .needs_ring = true },
    .{ .name = "stz_watch", .entry = "src/stz_watch_entry.zig", .needs_ring = true },
    .{ .name = "stz_cache", .entry = "src/stz_cache_entry.zig", .needs_ring = true },
    .{ .name = "stz_stream", .entry = "src/stz_stream_entry.zig", .needs_ring = true },
    .{ .name = "stz_process", .entry = "src/stz_process_entry.zig", .needs_ring = true },
    .{ .name = "stz_arith", .entry = "src/stz_arith_entry.zig", .needs_ring = true },
    .{ .name = "stz_profiler", .entry = "src/stz_profiler_entry.zig", .needs_ring = true },
    .{ .name = "stz_crypto", .entry = "src/stz_crypto_entry.zig", .needs_ring = true },
    .{ .name = "stz_embed", .entry = "src/stz_embed_entry.zig", .needs_ring = true },
    .{ .name = "stz_smallfn", .entry = "src/stz_smallfn_entry.zig", .needs_ring = true },
    .{ .name = "stz_numtheory", .entry = "src/stz_numtheory_entry.zig", .needs_ring = true },
    .{ .name = "stz_splitter", .entry = "src/stz_splitter_entry.zig", .needs_ring = true },
    .{ .name = "stz_pattern", .entry = "src/stz_pattern_entry.zig", .needs_ring = true },
    .{ .name = "stz_stringart", .entry = "src/stz_stringart_entry.zig", .needs_ring = true },
    .{ .name = "stz_display", .entry = "src/stz_display_entry.zig", .needs_ring = true },
    .{ .name = "stz_constraint", .entry = "src/stz_constraint_entry.zig", .needs_ring = true },
    .{ .name = "stz_natlang", .entry = "src/stz_natlang_entry.zig", .needs_ring = true },
    .{ .name = "stz_ccode", .entry = "src/stz_ccode_entry.zig", .needs_ring = true },
    .{ .name = "stz_reactive", .entry = "src/stz_reactive_entry.zig", .needs_ring = true },
    .{ .name = "stz_namedvars", .entry = "src/stz_namedvars_entry.zig", .needs_ring = true },
    .{ .name = "stz_adverb", .entry = "src/stz_adverb_entry.zig", .needs_ring = true },
    .{ .name = "stz_timeline", .entry = "src/stz_timeline_entry.zig", .needs_ring = true },
    .{ .name = "stz_gridnav", .entry = "src/stz_gridnav_entry.zig", .needs_ring = true },
    .{ .name = "stz_sectmerge", .entry = "src/stz_sectmerge_entry.zig", .needs_ring = true },
    .{ .name = "stz_deepops", .entry = "src/stz_deepops_entry.zig", .needs_ring = true },
    .{ .name = "stz_reaxis", .entry = "src/stz_reaxis_entry.zig", .needs_ring = true },
    .{ .name = "stz_softanzuter", .entry = "src/stz_softanzuter_entry.zig", .needs_ring = true },
    .{ .name = "stz_similarity", .entry = "src/stz_similarity_entry.zig", .needs_ring = true },
    .{ .name = "stz_validator", .entry = "src/stz_validator_entry.zig", .needs_ring = true },
    .{ .name = "stz_sequence", .entry = "src/stz_sequence_entry.zig", .needs_ring = true },
    .{ .name = "stz_intseq", .entry = "src/stz_intseq_entry.zig", .needs_ring = true },
    .{ .name = "stz_relations", .entry = "src/stz_relations_entry.zig", .needs_ring = true },
    .{ .name = "stz_statemachine", .entry = "src/stz_statemachine_entry.zig", .needs_ring = true },
    // Modern/neural tier: vendored ggml (CPU-only) for runtime GGUF inference.
    .{ .name = "stz_neural", .entry = "src/stz_neural_entry.zig", .needs_ring = true, .needs_ggml = true },
};

fn addUtf8proc(mod: *std.Build.Module, lib: *std.Build.Step.Compile, b: *std.Build) void {
    mod.addIncludePath(b.path("vendor/utf8proc"));
    lib.addCSourceFiles(.{
        .files = &.{"vendor/utf8proc/utf8proc.c"},
        .flags = &.{"-DUTF8PROC_STATIC"},
    });
}

// Snowball stemmer (libstemmer) -- English UTF-8 only, minimal footprint.
fn addSnowball(mod: *std.Build.Module, lib: *std.Build.Step.Compile, b: *std.Build) void {
    mod.addIncludePath(b.path("vendor/snowball/runtime"));
    mod.addIncludePath(b.path("vendor/snowball/src_c"));
    lib.addCSourceFiles(.{
        .files = &.{
            "vendor/snowball/runtime/api.c",
            "vendor/snowball/runtime/utilities.c",
            "vendor/snowball/src_c/stem_UTF_8_arabic.c",
            "vendor/snowball/src_c/stem_UTF_8_basque.c",
            "vendor/snowball/src_c/stem_UTF_8_catalan.c",
            "vendor/snowball/src_c/stem_UTF_8_danish.c",
            "vendor/snowball/src_c/stem_UTF_8_dutch.c",
            "vendor/snowball/src_c/stem_UTF_8_english.c",
            "vendor/snowball/src_c/stem_UTF_8_finnish.c",
            "vendor/snowball/src_c/stem_UTF_8_french.c",
            "vendor/snowball/src_c/stem_UTF_8_german.c",
            "vendor/snowball/src_c/stem_UTF_8_greek.c",
            "vendor/snowball/src_c/stem_UTF_8_hindi.c",
            "vendor/snowball/src_c/stem_UTF_8_hungarian.c",
            "vendor/snowball/src_c/stem_UTF_8_indonesian.c",
            "vendor/snowball/src_c/stem_UTF_8_irish.c",
            "vendor/snowball/src_c/stem_UTF_8_italian.c",
            "vendor/snowball/src_c/stem_UTF_8_lithuanian.c",
            "vendor/snowball/src_c/stem_UTF_8_nepali.c",
            "vendor/snowball/src_c/stem_UTF_8_norwegian.c",
            "vendor/snowball/src_c/stem_UTF_8_portuguese.c",
            "vendor/snowball/src_c/stem_UTF_8_romanian.c",
            "vendor/snowball/src_c/stem_UTF_8_russian.c",
            "vendor/snowball/src_c/stem_UTF_8_spanish.c",
            "vendor/snowball/src_c/stem_UTF_8_swedish.c",
            "vendor/snowball/src_c/stem_UTF_8_tamil.c",
            "vendor/snowball/src_c/stem_UTF_8_turkish.c",
        },
    });
}

// Vendored ggml (CPU-only) -- the modern/neural inference core. Compiled from
// source like utf8proc/pcre2/snowball; GPU backends pruned. GGML_VERSION/COMMIT
// are normally injected by CMake, so we define them. C and C++ are split (C++
// needs c++17 + libc++).
fn addGgml(mod: *std.Build.Module, lib: *std.Build.Step.Compile, b: *std.Build) void {
    const g = "vendor/ggml";
    mod.addIncludePath(b.path(g ++ "/include"));
    mod.addIncludePath(b.path(g ++ "/src"));
    mod.addIncludePath(b.path(g ++ "/src/ggml-cpu"));
    mod.addIncludePath(b.path(g ++ "/src/ggml-cpu/arch/x86"));

    const cflags = &[_][]const u8{
        "-DGGML_VERSION=\"0.0.0-stz\"",
        "-DGGML_COMMIT=\"stz\"",
        "-DGGML_USE_CPU",
        "-DGGML_SCHED_MAX_COPIES=4",
        "-DNDEBUG",
        // ggml's own C relies on pointer arithmetic UBSan flags as UB (null+offset
        // in graph/hash-set code). It's vendored third-party code, not ours, and
        // works in production (llama.cpp) -- don't run it under our UBSan.
        "-fno-sanitize=undefined",
    };
    lib.addCSourceFiles(.{
        .files = &.{
            g ++ "/src/ggml.c",
            g ++ "/src/ggml-alloc.c",
            g ++ "/src/ggml-quants.c",
            g ++ "/src/ggml-cpu/ggml-cpu.c",
            g ++ "/src/ggml-cpu/quants.c",
            g ++ "/src/ggml-cpu/arch/x86/quants.c",
        },
        .flags = cflags,
    });

    const cxxflags = &[_][]const u8{
        "-DGGML_VERSION=\"0.0.0-stz\"",
        "-DGGML_COMMIT=\"stz\"",
        "-DGGML_USE_CPU",
        "-DGGML_SCHED_MAX_COPIES=4",
        "-DNDEBUG",
        "-std=c++17",
        "-fno-sanitize=undefined",
    };
    lib.addCSourceFiles(.{
        .files = &.{
            g ++ "/src/ggml.cpp",
            g ++ "/src/ggml-threading.cpp",
            g ++ "/src/ggml-backend.cpp",
            g ++ "/src/ggml-backend-reg.cpp",
            g ++ "/src/ggml-backend-meta.cpp",
            g ++ "/src/ggml-backend-dl.cpp",
            g ++ "/src/gguf.cpp",
            g ++ "/src/ggml-cpu/ggml-cpu.cpp",
            g ++ "/src/ggml-cpu/ops.cpp",
            g ++ "/src/ggml-cpu/vec.cpp",
            g ++ "/src/ggml-cpu/binary-ops.cpp",
            g ++ "/src/ggml-cpu/unary-ops.cpp",
            g ++ "/src/ggml-cpu/traits.cpp",
            g ++ "/src/ggml-cpu/repack.cpp",
            g ++ "/src/ggml-cpu/arch/x86/cpu-feats.cpp",
            g ++ "/src/ggml-cpu/arch/x86/repack.cpp",
        },
        .flags = cxxflags,
    });
    lib.linkLibCpp();
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

// Vendored libuv (Tier 2 reactor backbone) -- compiled from source like
// utf8proc / pcre2 / sqlite. File lists + defines + system libs mirror
// libuv's own CMakeLists.txt (v1.52.1).
fn addLibuv(mod: *std.Build.Module, lib: *std.Build.Step.Compile, b: *std.Build, os_tag: std.Target.Os.Tag) void {
    const uv = "vendor/libuv";
    mod.addIncludePath(b.path(uv ++ "/include"));
    mod.addIncludePath(b.path(uv ++ "/src"));

    const common = [_][]const u8{
        uv ++ "/src/fs-poll.c",
        uv ++ "/src/idna.c",
        uv ++ "/src/inet.c",
        uv ++ "/src/random.c",
        uv ++ "/src/strscpy.c",
        uv ++ "/src/strtok.c",
        uv ++ "/src/thread-common.c",
        uv ++ "/src/threadpool.c",
        uv ++ "/src/timer.c",
        uv ++ "/src/uv-common.c",
        uv ++ "/src/uv-data-getter-setters.c",
        uv ++ "/src/version.c",
    };

    const win_sources = [_][]const u8{
        uv ++ "/src/win/async.c",        uv ++ "/src/win/core.c",
        uv ++ "/src/win/detect-wakeup.c", uv ++ "/src/win/dl.c",
        uv ++ "/src/win/error.c",        uv ++ "/src/win/fs.c",
        uv ++ "/src/win/fs-event.c",     uv ++ "/src/win/getaddrinfo.c",
        uv ++ "/src/win/getnameinfo.c",  uv ++ "/src/win/handle.c",
        uv ++ "/src/win/loop-watcher.c", uv ++ "/src/win/pipe.c",
        uv ++ "/src/win/poll.c",         uv ++ "/src/win/process.c",
        uv ++ "/src/win/process-stdio.c", uv ++ "/src/win/signal.c",
        uv ++ "/src/win/snprintf.c",     uv ++ "/src/win/stream.c",
        uv ++ "/src/win/tcp.c",          uv ++ "/src/win/thread.c",
        uv ++ "/src/win/tty.c",          uv ++ "/src/win/udp.c",
        uv ++ "/src/win/util.c",         uv ++ "/src/win/winapi.c",
        uv ++ "/src/win/winsock.c",
    };

    const unix_common = [_][]const u8{
        uv ++ "/src/unix/async.c",       uv ++ "/src/unix/core.c",
        uv ++ "/src/unix/dl.c",          uv ++ "/src/unix/fs.c",
        uv ++ "/src/unix/getaddrinfo.c", uv ++ "/src/unix/getnameinfo.c",
        uv ++ "/src/unix/loop-watcher.c", uv ++ "/src/unix/loop.c",
        uv ++ "/src/unix/pipe.c",        uv ++ "/src/unix/poll.c",
        uv ++ "/src/unix/process.c",     uv ++ "/src/unix/random-devurandom.c",
        uv ++ "/src/unix/signal.c",      uv ++ "/src/unix/stream.c",
        uv ++ "/src/unix/tcp.c",         uv ++ "/src/unix/thread.c",
        uv ++ "/src/unix/tty.c",         uv ++ "/src/unix/udp.c",
        uv ++ "/src/unix/proctitle.c",
    };
    const linux_sources = [_][]const u8{
        uv ++ "/src/unix/linux.c",
        uv ++ "/src/unix/procfs-exepath.c",
        uv ++ "/src/unix/random-getrandom.c",
        uv ++ "/src/unix/random-sysctl-linux.c",
    };
    const darwin_sources = [_][]const u8{
        uv ++ "/src/unix/bsd-ifaddrs.c",
        uv ++ "/src/unix/darwin.c",
        uv ++ "/src/unix/darwin-proctitle.c",
        uv ++ "/src/unix/fsevents.c",
        uv ++ "/src/unix/kqueue.c",
        uv ++ "/src/unix/random-getentropy.c",
    };

    const win_flags = [_][]const u8{ "-DWIN32_LEAN_AND_MEAN", "-D_WIN32_WINNT=0x0A00", "-D_CRT_DECLARE_NONSTDC_NAMES=0" };
    const linux_flags = [_][]const u8{ "-D_GNU_SOURCE", "-D_POSIX_C_SOURCE=200112", "-D_FILE_OFFSET_BITS=64", "-D_LARGEFILE_SOURCE" };
    const darwin_flags = [_][]const u8{ "-D_DARWIN_USE_64_BIT_INODE=1", "-D_DARWIN_UNLIMITED_SELECT=1" };

    const flags: []const []const u8 = switch (os_tag) {
        .windows => &win_flags,
        .macos => &darwin_flags,
        else => &linux_flags,
    };

    lib.addCSourceFiles(.{ .files = &common, .flags = flags });
    switch (os_tag) {
        .windows => {
            lib.addCSourceFiles(.{ .files = &win_sources, .flags = flags });
            const win_libs = [_][]const u8{ "psapi", "user32", "advapi32", "iphlpapi", "userenv", "ws2_32", "dbghelp", "ole32", "shell32" };
            for (win_libs) |l| lib.linkSystemLibrary(l);
        },
        .macos => {
            lib.addCSourceFiles(.{ .files = &unix_common, .flags = flags });
            lib.addCSourceFiles(.{ .files = &darwin_sources, .flags = flags });
            lib.linkFramework("CoreFoundation");
            lib.linkFramework("CoreServices");
        },
        else => {
            lib.addCSourceFiles(.{ .files = &unix_common, .flags = flags });
            lib.addCSourceFiles(.{ .files = &linux_sources, .flags = flags });
            lib.linkSystemLibrary("pthread");
            lib.linkSystemLibrary("dl");
            lib.linkSystemLibrary("rt");
        },
    }
}

// Vendored libcurl (Tier 2 HTTP stack -- HTTP/1.1+2, TLS, pooling, DNS).
// Compiled from source like our other C deps. On Windows, curl_setup.h
// pulls in lib/config-win32.h automatically (HAVE_CONFIG_H is NOT
// defined), giving a CMake-free build; TLS is native Schannel (no extra
// dependency). Sources are globbed from the 6 lib dirs at configure time
// so the list tracks the vendored tree. POSIX needs a generated
// curl_config.h (future work); Windows is the supported target today.
fn addLibcurl(mod: *std.Build.Module, lib: *std.Build.Step.Compile, b: *std.Build, os_tag: std.Target.Os.Tag) void {
    const cu = "vendor/curl";
    mod.addIncludePath(b.path(cu ++ "/include"));
    mod.addIncludePath(b.path(cu ++ "/lib"));

    if (os_tag != .windows) {
        std.debug.panic("libcurl vendoring is currently Windows-only (POSIX needs a generated curl_config.h)", .{});
    }

    var files: std.ArrayList([]const u8) = .{};
    const subdirs = [_][]const u8{ "lib", "lib/vauth", "lib/vtls", "lib/vquic", "lib/vssh", "lib/curlx" };
    for (subdirs) |sd| {
        const dirpath = b.fmt("{s}/{s}", .{ cu, sd });
        var dir = std.fs.cwd().openDir(dirpath, .{ .iterate = true }) catch |e|
            std.debug.panic("libcurl: cannot open {s}: {s}", .{ dirpath, @errorName(e) });
        defer dir.close();
        var it = dir.iterate();
        while (it.next() catch null) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".c")) continue;
            files.append(b.allocator, b.fmt("{s}/{s}", .{ dirpath, entry.name })) catch @panic("oom");
        }
    }

    // HTTP/2 via vendored nghttp2 (compiled below); tell curl to use it
    // and to treat nghttp2 symbols as static (not dllimport).
    const ng = "vendor/nghttp2";
    mod.addIncludePath(b.path(ng ++ "/lib/includes"));
    mod.addIncludePath(b.path(ng ++ "/lib"));

    // gzip/deflate auto-decompression via vendored zlib.
    const zl = "vendor/zlib";
    mod.addIncludePath(b.path(zl));

    const flags = [_][]const u8{
        "-DBUILDING_LIBCURL",
        "-DCURL_STATICLIB",
        "-DUSE_WINDOWS_SSPI",
        "-DUSE_SCHANNEL",
        "-DUSE_NGHTTP2",
        "-DNGHTTP2_STATICLIB",
        "-DHAVE_LIBZ",
        "-DHAVE_ZLIB_H",
        // Trim to HTTP(S): drop protocols we don't ship (also avoids
        // pulling optional third-party deps).
        "-DCURL_DISABLE_LDAP",   "-DCURL_DISABLE_LDAPS",
        "-DCURL_DISABLE_DICT",   "-DCURL_DISABLE_FILE",
        "-DCURL_DISABLE_FTP",    "-DCURL_DISABLE_GOPHER",
        "-DCURL_DISABLE_IMAP",   "-DCURL_DISABLE_MQTT",
        "-DCURL_DISABLE_POP3",   "-DCURL_DISABLE_RTSP",
        "-DCURL_DISABLE_SMB",    "-DCURL_DISABLE_SMTP",
        "-DCURL_DISABLE_TELNET", "-DCURL_DISABLE_TFTP",
    };
    lib.addCSourceFiles(.{ .files = files.items, .flags = &flags });

    // Compile vendored nghttp2 (HTTP/2) into the same DLL. No config.h
    // needed (ssize_t comes from the MinGW headers zig cc uses).
    var ngfiles: std.ArrayList([]const u8) = .{};
    {
        const dirpath = ng ++ "/lib";
        var dir = std.fs.cwd().openDir(dirpath, .{ .iterate = true }) catch |e|
            std.debug.panic("nghttp2: cannot open {s}: {s}", .{ dirpath, @errorName(e) });
        defer dir.close();
        var it = dir.iterate();
        while (it.next() catch null) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".c")) continue;
            ngfiles.append(b.allocator, b.fmt("{s}/{s}", .{ dirpath, entry.name })) catch @panic("oom");
        }
    }
    const ng_flags = [_][]const u8{ "-DNGHTTP2_STATICLIB", "-DBUILDING_NGHTTP2" };
    lib.addCSourceFiles(.{ .files = ngfiles.items, .flags = &ng_flags });

    // Compile vendored zlib (flat .c list; zconf.h is committed -- no gen).
    var zfiles: std.ArrayList([]const u8) = .{};
    {
        var dir = std.fs.cwd().openDir(zl, .{ .iterate = true }) catch |e|
            std.debug.panic("zlib: cannot open {s}: {s}", .{ zl, @errorName(e) });
        defer dir.close();
        var it = dir.iterate();
        while (it.next() catch null) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".c")) continue;
            zfiles.append(b.allocator, b.fmt("{s}/{s}", .{ zl, entry.name })) catch @panic("oom");
        }
    }
    const zl_flags = [_][]const u8{"-DHAVE_UNISTD_H=0"};
    lib.addCSourceFiles(.{ .files = zfiles.items, .flags = &zl_flags });

    const win_libs = [_][]const u8{ "ws2_32", "crypt32", "secur32", "advapi32", "bcrypt", "normaliz" };
    for (win_libs) |l| lib.linkSystemLibrary(l);
}

fn addRing(b: *std.Build, mod: *std.Build.Module, lib: *std.Build.Step.Compile, ring_dir: []const u8) void {
    mod.addIncludePath(.{ .cwd_relative = b.fmt("{s}/language/include", .{ring_dir}) });
    lib.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{ring_dir}) });
    lib.linkSystemLibrary("ring");
}

// A Ring install is identified by the presence of its public header.
fn ringHasHeaders(b: *std.Build, dir: []const u8) bool {
    const probe = b.fmt("{s}/language/include/state.h", .{dir});
    std.fs.cwd().access(probe, .{}) catch return false;
    return true;
}

// Locate the `ring` executable on PATH and return its install dir (the parent
// of the bin/ directory, or the bin dir itself if headers live alongside).
fn findRingViaPath(b: *std.Build) ?[]const u8 {
    const exe = if (builtin.os.tag == .windows) "ring.exe" else "ring";
    const sep: u8 = if (builtin.os.tag == .windows) ';' else ':';
    const path = std.process.getEnvVarOwned(b.allocator, "PATH") catch return null;
    var it = std.mem.splitScalar(u8, path, sep);
    while (it.next()) |entry| {
        if (entry.len == 0) continue;
        const exe_path = b.fmt("{s}/{s}", .{ entry, exe });
        std.fs.cwd().access(exe_path, .{}) catch continue;
        if (std.fs.path.dirname(entry)) |parent| {
            if (ringHasHeaders(b, parent)) return parent;
        }
        if (ringHasHeaders(b, entry)) return entry;
    }
    return null;
}

// Scan common install roots for a ring<NNN> dir (newest with valid headers).
fn scanRootsForRing(b: *std.Build) ?[]const u8 {
    const home = std.process.getEnvVarOwned(b.allocator, if (builtin.os.tag == .windows) "USERPROFILE" else "HOME") catch null;
    const win_roots = [_][]const u8{ "C:/", "D:/", "E:/" };
    const nix_roots = [_][]const u8{ "/usr/local", "/opt", "/usr" };
    const roots: []const []const u8 = if (builtin.os.tag == .windows) &win_roots else &nix_roots;
    var best: ?[]const u8 = null;
    var best_n: u32 = 0;
    var root_i: usize = 0;
    const total = roots.len + @as(usize, if (home != null) 1 else 0);
    while (root_i < total) : (root_i += 1) {
        const root = if (root_i < roots.len) roots[root_i] else home.?;
        var dir = std.fs.cwd().openDir(root, .{ .iterate = true }) catch continue;
        defer dir.close();
        var it = dir.iterate();
        while (it.next() catch null) |entry| {
            if (entry.kind != .directory) continue;
            if (entry.name.len < 5 or !std.ascii.startsWithIgnoreCase(entry.name, "ring")) continue;
            const n = std.fmt.parseInt(u32, entry.name[4..], 10) catch continue;
            const cand = b.fmt("{s}/{s}", .{ root, entry.name });
            if (n > best_n and ringHasHeaders(b, cand)) {
                best_n = n;
                best = cand;
            }
        }
    }
    return best;
}

// Discover the Ring install without hardcoding a path, so any user's setup
// works. Priority: env vars (RING_HOME/RING_PATH/RING) -> `ring` on PATH ->
// scan common roots. Override anytime with `zig build -Dring=PATH`.
fn discoverRingDir(b: *std.Build) ?[]const u8 {
    const env_names = [_][]const u8{ "RING_HOME", "RING_PATH", "RING" };
    for (env_names) |name| {
        if (std.process.getEnvVarOwned(b.allocator, name)) |val| {
            if (ringHasHeaders(b, val)) return val;
        } else |_| {}
    }
    if (findRingViaPath(b)) |d| return d;
    if (scanRootsForRing(b)) |d| return d;
    return null;
}

// Read RING_VERSION_MINOR from <ring_dir>/language/include/state.h so the
// engine can match the Ring ABI (the internal List struct layout changed in
// 1.27). Defaults to 27 if the header can't be read/parsed.
fn readRingMinor(b: *std.Build, ring_dir: []const u8) u32 {
    const path = b.fmt("{s}/language/include/state.h", .{ring_dir});
    const data = std.fs.cwd().readFileAlloc(b.allocator, path, 1 << 20) catch return 27;
    const needle = "RING_VERSION_MINOR";
    const at = std.mem.indexOf(u8, data, needle) orelse return 27;
    var i = at + needle.len;
    while (i < data.len and (data[i] == ' ' or data[i] == '\t')) : (i += 1) {}
    var n: u32 = 0;
    var found = false;
    while (i < data.len and data[i] >= '0' and data[i] <= '9') : (i += 1) {
        n = n * 10 + (data[i] - '0');
        found = true;
    }
    return if (found) n else 27;
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

    // NOTE: we tried building stz_neural with the msvc ABI (so C++ global ctors
    // land in .CRT$XCU and can be run at load) -- BLOCKED by a Zig 0.15.2 bug:
    // its bundled libc++abi fails to compile for x86_64-windows-msvc
    // (stdlib_stdexcept.cpp declaration mismatch). So stz_neural stays on the
    // default (gnu) ABI, and ggml's C++ static state is initialised via
    // ctor-independent per-global patches (see vendor/ggml/NOTICE + gguf.cpp).
    const ggml_target = target;

    // Ring install to build against (override with -Dring=PATH). The Ring ABI
    // (internal List struct layout) changed in 1.27, so the engine must be
    // built for the Ring version it will run under. We read the minor version
    // from the chosen install's state.h and expose it to the Zig code.
    const ring_dir = b.option([]const u8, "ring", "Ring install directory (auto-detected from RING_HOME / PATH if omitted)") orelse (discoverRingDir(b) orelse {
        std.debug.print(
            \\
            \\[softanza] ERROR: could not locate a Ring installation.
            \\  Fix one of:
            \\   * pass it explicitly:   zig build -Dring=/path/to/ring
            \\   * set an env var:        RING_HOME=/path/to/ring   (or RING_PATH / RING)
            \\   * put ring on your PATH  (so `ring`/`ring.exe` is found)
            \\  A valid dir contains:    <dir>/language/include/state.h
            \\
        , .{});
        @panic("Ring installation not found");
    });
    const ring_minor = readRingMinor(b, ring_dir);
    std.debug.print("[softanza] building against Ring dir='{s}' minor={d}\n", .{ ring_dir, ring_minor });
    const ring_opts = b.addOptions();
    ring_opts.addOption(u32, "ring_minor", ring_minor);
    const ring_opts_mod = ring_opts.createModule();

    // Core layer DLLs
    for (core_domains) |dom| {
        const mod = b.createModule(.{
            .root_source_file = b.path(dom.entry),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        mod.addImport("ring_build_options", ring_opts_mod);
        const lib = b.addLibrary(.{
            .name = @constCast(dom.name),
            .root_module = mod,
            .linkage = .dynamic,
        });
        if (dom.needs_utf8proc) addUtf8proc(mod, lib, b);
        if (dom.needs_pcre2) addPcre2(mod, lib, b);
        if (dom.needs_snowball) addSnowball(mod, lib, b);
        if (dom.needs_ring) addRing(b, mod, lib, ring_dir);
        if (dom.needs_sqlite) addSqlite(mod, lib, b);
        b.installArtifact(lib);
    }

    // Base layer DLLs
    for (base_domains) |dom| {
        const mod = b.createModule(.{
            .root_source_file = b.path(dom.entry),
            .target = if (dom.needs_ggml) ggml_target else target,
            .optimize = optimize,
            .link_libc = true,
        });
        mod.addImport("ring_build_options", ring_opts_mod);
        const lib = b.addLibrary(.{
            .name = @constCast(dom.name),
            .root_module = mod,
            .linkage = .dynamic,
        });
        if (dom.needs_utf8proc) addUtf8proc(mod, lib, b);
        if (dom.needs_pcre2) addPcre2(mod, lib, b);
        if (dom.needs_snowball) addSnowball(mod, lib, b);
        if (dom.needs_ring) addRing(b, mod, lib, ring_dir);
        if (dom.needs_sqlite) addSqlite(mod, lib, b);
        if (dom.needs_libuv) addLibuv(mod, lib, b, target.result.os.tag);
        if (dom.needs_libcurl) addLibcurl(mod, lib, b, target.result.os.tag);
        if (dom.needs_ggml) addGgml(mod, lib, b);
        b.installArtifact(lib);
    }

    // Static library linking everything (for Zin direct linking / CLI)
    const static_mod = b.createModule(.{
        .root_source_file = b.path("src/engine.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    static_mod.addImport("ring_build_options", ring_opts_mod);
    const static_lib = b.addLibrary(.{
        .name = "softanza_engine_static",
        .root_module = static_mod,
        .linkage = .static,
    });
    addUtf8proc(static_mod, static_lib, b);
    addPcre2(static_mod, static_lib, b);
    addSnowball(static_mod, static_lib, b);
    addSqlite(static_mod, static_lib, b);
    b.installArtifact(static_lib);

    // Tests run through engine.zig (covers all modules)
    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/engine.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    test_mod.addImport("ring_build_options", ring_opts_mod);
    const tests = b.addTest(.{ .root_module = test_mod });
    addUtf8proc(test_mod, tests, b);
    addPcre2(test_mod, tests, b);
    addSnowball(test_mod, tests, b);
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
