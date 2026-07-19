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

fn ring_ngram_add_doc(p: *anyopaque) callconv(.c) void {
    const h = R.getHandle(p, 1) orelse return;
    const m: *ngram.NgramModel = @ptrCast(@alignCast(h));
    const s: [*]const u8 = @ptrCast(gs(p, 2));
    const l: usize = @intCast(gss(p, 2));
    ngram.addDoc(m, s[0..l]);
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

// ─── vocabulary / frequency / TF-IDF, all engine-side ───

fn modelOf(p: *anyopaque) ?*ngram.NgramModel {
    const h = R.getHandle(p, 1) orelse return null;
    return @ptrCast(@alignCast(h));
}

fn ring_ngram_uni_count(p: *anyopaque) callconv(.c) void {
    const m = modelOf(p) orelse return rn(p, 0);
    const w: [*]const u8 = @ptrCast(gs(p, 2));
    const l: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(ngram.uniCount(m, w[0..l])));
}

fn ring_ngram_doc_count(p: *anyopaque) callconv(.c) void {
    const m = modelOf(p) orelse return rn(p, 0);
    rn(p, @floatFromInt(ngram.docCount(m)));
}

fn ring_ngram_tf(p: *anyopaque) callconv(.c) void {
    const m = modelOf(p) orelse return rn(p, 0);
    const w: [*]const u8 = @ptrCast(gs(p, 2));
    const l: usize = @intCast(gss(p, 2));
    const doc: usize = @intFromFloat(gn(p, 3));
    rn(p, @floatFromInt(ngram.tf(m, w[0..l], doc)));
}

fn ring_ngram_df(p: *anyopaque) callconv(.c) void {
    const m = modelOf(p) orelse return rn(p, 0);
    const w: [*]const u8 = @ptrCast(gs(p, 2));
    const l: usize = @intCast(gss(p, 2));
    rn(p, @floatFromInt(ngram.dfOf(m, w[0..l])));
}

fn ring_ngram_idf(p: *anyopaque) callconv(.c) void {
    const m = modelOf(p) orelse return rn(p, 0);
    const w: [*]const u8 = @ptrCast(gs(p, 2));
    const l: usize = @intCast(gss(p, 2));
    rn(p, ngram.idf(m, w[0..l]));
}

// Returns the whole vocabulary as a flat Ring list of strings.
fn ring_ngram_vocab(p: *anyopaque) callconv(.c) void {
    const m = modelOf(p) orelse return;
    const out = R.ring_vm_api_newlist(p) orelse return;
    var it = m.uni.keyIterator();
    while (it.next()) |k| {
        R.ring_list_addstring2(out, k.*.ptr, @intCast(k.*.len));
    }
    R.ring_vm_api_retlist(p, out);
}

// Returns the top-n words by count as a Ring list of [ word, count ] pairs.
fn ring_ngram_most_frequent(p: *anyopaque) callconv(.c) void {
    const m = modelOf(p) orelse return;
    const nreq: usize = @intFromFloat(gn(p, 2));
    const entries = ngram.mostFrequent(m);
    defer ngram.freeEntries(entries);
    const take = @min(nreq, entries.len);
    const out = R.ring_vm_api_newlist(p) orelse return;
    var i: usize = 0;
    while (i < take) : (i += 1) {
        const sub = R.ring_list_newlist(out) orelse continue;
        R.ring_list_addstring2(sub, entries[i].word.ptr, @intCast(entries[i].word.len));
        R.ring_list_adddouble(sub, @floatFromInt(entries[i].count));
    }
    R.ring_vm_api_retlist(p, out);
}

// Returns document doc_idx's top-n terms by TF-IDF as [ word, tfidf ] pairs.
fn ring_ngram_top_terms(p: *anyopaque) callconv(.c) void {
    const m = modelOf(p) orelse return;
    const doc: usize = @intFromFloat(gn(p, 2));
    const nreq: usize = @intFromFloat(gn(p, 3));
    const entries = ngram.topTerms(m, doc);
    defer ngram.freeEntriesF(entries);
    const take = @min(nreq, entries.len);
    const out = R.ring_vm_api_newlist(p) orelse return;
    var i: usize = 0;
    while (i < take) : (i += 1) {
        const sub = R.ring_list_newlist(out) orelse continue;
        R.ring_list_addstring2(sub, entries[i].word.ptr, @intCast(entries[i].word.len));
        R.ring_list_adddouble(sub, entries[i].score);
    }
    R.ring_vm_api_retlist(p, out);
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
    .{ .name = "stzengine_ngram_add_doc", .func = ring_ngram_add_doc },
    .{ .name = "stzengine_ngram_bigram_prob", .func = ring_ngram_bigram_prob },
    .{ .name = "stzengine_ngram_log_prob", .func = ring_ngram_log_prob },
    .{ .name = "stzengine_ngram_token_count", .func = ring_ngram_token_count },
    .{ .name = "stzengine_ngram_vocab_size", .func = ring_ngram_vocab_size },
    .{ .name = "stzengine_ngram_free", .func = ring_ngram_free },
    .{ .name = "stzengine_ngram_uni_count", .func = ring_ngram_uni_count },
    .{ .name = "stzengine_ngram_doc_count", .func = ring_ngram_doc_count },
    .{ .name = "stzengine_ngram_tf", .func = ring_ngram_tf },
    .{ .name = "stzengine_ngram_df", .func = ring_ngram_df },
    .{ .name = "stzengine_ngram_idf", .func = ring_ngram_idf },
    .{ .name = "stzengine_ngram_vocab", .func = ring_ngram_vocab },
    .{ .name = "stzengine_ngram_most_frequent", .func = ring_ngram_most_frequent },
    .{ .name = "stzengine_ngram_top_terms", .func = ring_ngram_top_terms },
};
