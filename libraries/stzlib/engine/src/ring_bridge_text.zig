const text = @import("text.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const g = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_ParagraphCount(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(text.text_paragraph_count(ptr, len)));
}

fn ring_SplitParagraphs(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = text.text_split_paragraphs(ptr, len, &buf, 65536);
    rs2(p, &buf, @intCast(out_len));
}

fn ring_SentenceCount(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(text.text_sentence_count(ptr, len)));
}

fn ring_SplitSentences(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    var buf: [65536]u8 = undefined;
    const out_len = text.text_split_sentences(ptr, len, &buf, 65536);
    rs2(p, &buf, @intCast(out_len));
}

fn ring_WordCount(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(text.text_word_count(ptr, len)));
}

fn ring_CharCount(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(text.text_char_count(ptr, len)));
}

fn ring_LineCount(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(text.text_line_count(ptr, len)));
}

fn ring_SyllableCount(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(text.text_syllable_count(ptr, len)));
}

fn ring_FleschReadingEase(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @as(f64, @floatFromInt(text.text_flesch_reading_ease(ptr, len))) / 100.0);
}

fn ring_FleschKincaidGrade(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @as(f64, @floatFromInt(text.text_flesch_kincaid_grade(ptr, len))) / 100.0);
}

fn ring_Truncate(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    const max_words: i32 = @intFromFloat(g(p, 2));
    var buf: [65536]u8 = undefined;
    const out_len = text.text_truncate(ptr, len, max_words, &buf, 65536);
    rs2(p, &buf, @intCast(out_len));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginetextparagraphcount", .func = &ring_ParagraphCount },
    .{ .name = "stzenginetextsplitparagraphs", .func = &ring_SplitParagraphs },
    .{ .name = "stzenginetextsentencecount", .func = &ring_SentenceCount },
    .{ .name = "stzenginetextsplitsentences", .func = &ring_SplitSentences },
    .{ .name = "stzenginetextwordcount", .func = &ring_WordCount },
    .{ .name = "stzenginetextcharcount", .func = &ring_CharCount },
    .{ .name = "stzenginetextlinecount", .func = &ring_LineCount },
    .{ .name = "stzenginetextsyllablecount", .func = &ring_SyllableCount },
    .{ .name = "stzenginetextfleschreadingease", .func = &ring_FleschReadingEase },
    .{ .name = "stzenginetextfleschkincaidgrade", .func = &ring_FleschKincaidGrade },
    .{ .name = "stzenginetexttruncate", .func = &ring_Truncate },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
