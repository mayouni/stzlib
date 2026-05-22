const ref_data = @import("ref_data.zig");
const R = @import("ring_api.zig");

const g = R.ring_vm_api_getnumber;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;

fn ring_ScriptCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.scriptCount()));
}

fn ring_ScriptName(p: *anyopaque) callconv(.c) void {
    const code: i32 = @intFromFloat(g(p, 1));
    var buf: [256]u8 = undefined;
    const len = ref_data.scriptName(code, &buf, 256);
    rs2(p, &buf, @intCast(len));
}

fn ring_DirectionCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.directionCount()));
}

fn ring_DirectionName(p: *anyopaque) callconv(.c) void {
    const nbr: i32 = @intFromFloat(g(p, 1));
    var buf: [256]u8 = undefined;
    const len = ref_data.directionName(nbr, &buf, 256);
    rs2(p, &buf, @intCast(len));
}

fn ring_CategoryCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.categoryCount()));
}

fn ring_CategoryName(p: *anyopaque) callconv(.c) void {
    const nbr: i32 = @intFromFloat(g(p, 1));
    var buf: [256]u8 = undefined;
    const len = ref_data.categoryName(nbr, &buf, 256);
    rs2(p, &buf, @intCast(len));
}

fn ring_RegexCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.regexPatternCount()));
}

fn ring_RegexPattern(p: *anyopaque) callconv(.c) void {
    const name_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: i32 = @intCast(gss(p, 1));
    var buf: [4096]u8 = undefined;
    const len = ref_data.regexPattern(name_ptr, name_len, &buf, 4096);
    rs2(p, &buf, @intCast(len));
}

fn ring_WordCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.wordCount()));
}

fn ring_WordAt(p: *anyopaque) callconv(.c) void {
    const idx: i32 = @intFromFloat(g(p, 1));
    const lang: i32 = @intFromFloat(g(p, 2));
    var buf: [256]u8 = undefined;
    const len = ref_data.wordAt(idx, lang, &buf, 256);
    rs2(p, &buf, @intCast(len));
}

fn ring_BoxDrawCharCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.boxDrawCharCount()));
}

fn ring_BoxDrawChar(p: *anyopaque) callconv(.c) void {
    const name_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: i32 = @intCast(gss(p, 1));
    var buf: [64]u8 = undefined;
    const len = ref_data.boxDrawChar(name_ptr, name_len, &buf, 64);
    rs2(p, &buf, @intCast(len));
}

fn ring_InvertibleCharCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.invertibleCharCount()));
}

fn ring_InvertedOf(p: *anyopaque) callconv(.c) void {
    const char_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const char_len: i32 = @intCast(gss(p, 1));
    var buf: [16]u8 = undefined;
    const len = ref_data.invertedOf(char_ptr, char_len, &buf, 16);
    rs2(p, &buf, @intCast(len));
}

fn ring_LatinDiacriticCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.latinDiacriticCount()));
}

fn ring_LatinDiacriticBase(p: *anyopaque) callconv(.c) void {
    const diac_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const diac_len: i32 = @intCast(gss(p, 1));
    var buf: [16]u8 = undefined;
    const len = ref_data.latinDiacriticBase(diac_ptr, diac_len, &buf, 16);
    rs2(p, &buf, @intCast(len));
}

fn ring_SysCmdCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(ref_data.systemCommandCount()));
}

fn ring_SysCmd(p: *anyopaque) callconv(.c) void {
    const name_ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const name_len: i32 = @intCast(gss(p, 1));
    const platform: i32 = @intFromFloat(g(p, 2));
    var buf: [1024]u8 = undefined;
    const len = ref_data.systemCommand(name_ptr, name_len, platform, &buf, 1024);
    rs2(p, &buf, @intCast(len));
}

pub const regs = [_]R.Reg{
    .{ .name = "stzenginerefscriptcount", .func = &ring_ScriptCount },
    .{ .name = "stzenginerefscriptname", .func = &ring_ScriptName },
    .{ .name = "stzenginerefdirectioncount", .func = &ring_DirectionCount },
    .{ .name = "stzenginerefdirectionname", .func = &ring_DirectionName },
    .{ .name = "stzenginerefcategorycount", .func = &ring_CategoryCount },
    .{ .name = "stzenginerefcategoryname", .func = &ring_CategoryName },
    .{ .name = "stzenginerefregexcount", .func = &ring_RegexCount },
    .{ .name = "stzenginerefregexpattern", .func = &ring_RegexPattern },
    .{ .name = "stzenginerefwordcount", .func = &ring_WordCount },
    .{ .name = "stzenginerefwordat", .func = &ring_WordAt },
    .{ .name = "stzenginerefboxdrawcharcount", .func = &ring_BoxDrawCharCount },
    .{ .name = "stzenginerefboxdrawchar", .func = &ring_BoxDrawChar },
    .{ .name = "stzenginerefinvertiblecharcount", .func = &ring_InvertibleCharCount },
    .{ .name = "stzenginerefinvertedof", .func = &ring_InvertedOf },
    .{ .name = "stzenginereflatindiacriticcount", .func = &ring_LatinDiacriticCount },
    .{ .name = "stzenginereflatindiacriticbase", .func = &ring_LatinDiacriticBase },
    .{ .name = "stzenginerefrescmdcount", .func = &ring_SysCmdCount },
    .{ .name = "stzenginerefrescmd", .func = &ring_SysCmd },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
