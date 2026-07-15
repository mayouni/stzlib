// Fuzz harness for PCRE2 -- the regex engine (a classic UB/crash target). It
// processes untrusted PATTERNS and untrusted SUBJECTS. Compiled under UBSan-
// trap, so any undefined behavior in the compiler/matcher is an illegal-
// instruction crash that fails the step. Phase 1 compiles random patterns;
// phase 2 matches compiled patterns against random subjects.

const std = @import("std");
const c = @cImport({
    @cDefine("PCRE2_CODE_UNIT_WIDTH", "8");
    @cDefine("PCRE2_STATIC", "1");
    @cInclude("pcre2.h");
});

fn fuzzOne(pat: []const u8, subj: []const u8) void {
    var errcode: c_int = 0;
    var erroff: usize = 0;
    const re = c.pcre2_compile_8(pat.ptr, pat.len, 0, &errcode, &erroff, null);
    if (re == null) return; // rejected a bad pattern -> fine
    defer c.pcre2_code_free_8(re);
    const md = c.pcre2_match_data_create_from_pattern_8(re, null);
    if (md == null) return;
    defer c.pcre2_match_data_free_8(md);
    // a short subject bounds worst-case backtracking (no ReDoS hang)
    _ = c.pcre2_match_8(re, subj.ptr, subj.len, 0, 0, md, null);
}

pub fn main() void {
    // regex metacharacters, so random strings become plausible patterns
    const meta = "()[]{}.*+?|^$\\-abc0AZ, \t";
    var prng = std.Random.DefaultPrng.init(0x9E3779B9_1234);
    const rand = prng.random();
    var pat: [256]u8 = undefined;
    var subj: [64]u8 = undefined;
    var iter: usize = 0;
    const rounds: usize = 300_000;
    while (iter < rounds) : (iter += 1) {
        const plen = rand.uintLessThan(usize, pat.len);
        for (pat[0..plen]) |*ch| {
            ch.* = if (rand.uintLessThan(u8, 4) == 0) rand.int(u8) else meta[rand.uintLessThan(usize, meta.len)];
        }
        const slen = rand.uintLessThan(usize, subj.len);
        for (subj[0..slen]) |*ch| ch.* = rand.int(u8);
        fuzzOne(pat[0..plen], subj[0..slen]);
    }
    std.debug.print("PASS: {d} pcre2 compile+match inputs, no crash / UB.\n", .{rounds});
    std.process.exit(0);
}
