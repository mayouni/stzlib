const R = @import("ring_api.zig");
const natlang = @import("natlang.zig");
const ngram = @import("ngram.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;

fn ring_word_count(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.word_count(s, l)));
}

fn ring_sentence_count(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.sentence_count(s, l)));
}

fn ring_char_count(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.char_count(s, l)));
}

fn ring_syllable_count(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.syllable_count_word(s, l)));
}

fn ring_avg_word_len(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, natlang.avg_word_len(s, l));
}

fn ring_is_upper(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.is_uppercase_word(s, l)));
}

fn ring_is_lower(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.is_lowercase_word(s, l)));
}

fn ring_is_title(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.is_titlecase_word(s, l)));
}

fn ring_has_digits(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.has_digits(s, l)));
}

fn ring_is_alpha(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.is_all_alpha(s, l)));
}

fn ring_is_alnum(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(natlang.is_all_alnum(s, l)));
}

// ─── n-gram language model (owned end-to-end by the engine) ───
// The model is engine-resident, reached by a handle. It MUST be registered in
// THIS DLL: the handle table is per-DLL static state, so a function that
// resolves an ngram handle has to live where the handle was created.
//
// Ring hands over the RAW corpus (documents joined by '\n'); the engine
// tokenises, lowercases and counts. Ring never does the heavy work.

fn ring_ngram_train(p: *anyopaque) callconv(.c) void {
    const s: [*]const u8 = @ptrCast(gs(p, 1));
    const l: usize = @intCast(gss(p, 1));
    const m = ngram.train(s[0..l]);
    R.retHandle(p, @ptrCast(m)); // 0 on OOM
}

fn ring_ngram_bigram_prob(p: *anyopaque) callconv(.c) void {
    const h = R.getHandle(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const m: *ngram.NgramModel = @ptrCast(@alignCast(h));
    const w1: [*]const u8 = @ptrCast(gs(p, 2));
    const l1: usize = @intCast(gss(p, 2));
    const w2: [*]const u8 = @ptrCast(gs(p, 3));
    const l2: usize = @intCast(gss(p, 3));
    rn(p, ngram.bigramProb(m, w1[0..l1], w2[0..l2]));
}

fn ring_ngram_log_prob(p: *anyopaque) callconv(.c) void {
    const h = R.getHandle(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const m: *ngram.NgramModel = @ptrCast(@alignCast(h));
    const q: [*]const u8 = @ptrCast(gs(p, 2));
    const l: usize = @intCast(gss(p, 2));
    rn(p, ngram.logProb(m, q[0..l]));
}

fn ring_ngram_token_count(p: *anyopaque) callconv(.c) void {
    const h = R.getHandle(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const m: *ngram.NgramModel = @ptrCast(@alignCast(h));
    rn(p, @floatFromInt(ngram.tokenCount(m)));
}

fn ring_ngram_vocab_size(p: *anyopaque) callconv(.c) void {
    const h = R.getHandle(p, 1) orelse {
        rn(p, 0);
        return;
    };
    const m: *ngram.NgramModel = @ptrCast(@alignCast(h));
    rn(p, @floatFromInt(ngram.vocabSize(m)));
}

fn ring_ngram_free(p: *anyopaque) callconv(.c) void {
    const h = R.releaseHandle(p, 1) orelse return;
    const m: *ngram.NgramModel = @ptrCast(@alignCast(h));
    ngram.free(m);
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzengine_natlang_word_count", .func = ring_word_count },
    .{ .name = "stzengine_natlang_sentence_count", .func = ring_sentence_count },
    .{ .name = "stzengine_natlang_char_count", .func = ring_char_count },
    .{ .name = "stzengine_natlang_syllable_count", .func = ring_syllable_count },
    .{ .name = "stzengine_natlang_avg_word_len", .func = ring_avg_word_len },
    .{ .name = "stzengine_natlang_is_upper", .func = ring_is_upper },
    .{ .name = "stzengine_natlang_is_lower", .func = ring_is_lower },
    .{ .name = "stzengine_natlang_is_title", .func = ring_is_title },
    .{ .name = "stzengine_natlang_has_digits", .func = ring_has_digits },
    .{ .name = "stzengine_natlang_is_alpha", .func = ring_is_alpha },
    .{ .name = "stzengine_natlang_is_alnum", .func = ring_is_alnum },
    .{ .name = "stzengine_ngram_train", .func = ring_ngram_train },
    .{ .name = "stzengine_ngram_bigram_prob", .func = ring_ngram_bigram_prob },
    .{ .name = "stzengine_ngram_log_prob", .func = ring_ngram_log_prob },
    .{ .name = "stzengine_ngram_token_count", .func = ring_ngram_token_count },
    .{ .name = "stzengine_ngram_vocab_size", .func = ring_ngram_vocab_size },
    .{ .name = "stzengine_ngram_free", .func = ring_ngram_free },
};
