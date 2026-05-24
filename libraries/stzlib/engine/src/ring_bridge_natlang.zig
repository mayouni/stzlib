const R = @import("ring_api.zig");
const natlang = @import("natlang.zig");

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
};
