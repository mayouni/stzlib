const R = @import("ring_api.zig");
const mod = @import("polyglot.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Register(p: *anyopaque) callconv(.c) void {
    const token = gs(p, 1);
    const tok_len: usize = @intCast(gl(p, 1));
    const lang = gs(p, 2);
    const lang_len: usize = @intCast(gl(p, 2));
    const translation = gs(p, 3);
    const trans_len: usize = @intCast(gl(p, 3));
    rn(p, @floatFromInt(mod.stz_pg_register(token, tok_len, lang, lang_len, translation, trans_len)));
}

fn ring_Translate(p: *anyopaque) callconv(.c) void {
    const token = gs(p, 1);
    const tok_len: usize = @intCast(gl(p, 1));
    const lang = gs(p, 2);
    const lang_len: usize = @intCast(gl(p, 2));
    var buf: [256]u8 = undefined;
    const len = mod.stz_pg_translate(token, tok_len, lang, lang_len, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_HasToken(p: *anyopaque) callconv(.c) void {
    const token = gs(p, 1);
    const tok_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_pg_has_token(token, tok_len)));
}

fn ring_LangCount(p: *anyopaque) callconv(.c) void {
    const token = gs(p, 1);
    const tok_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_pg_lang_count(token, tok_len)));
}

fn ring_TokenCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_pg_token_count()));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_pg_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginepolyglotregister", .func = ring_Register },
    .{ .name = "stzenginepolyglottranslate", .func = ring_Translate },
    .{ .name = "stzenginepolyglothastoken", .func = ring_HasToken },
    .{ .name = "stzenginepolyglotlangcount", .func = ring_LangCount },
    .{ .name = "stzenginepolyglottokencount", .func = ring_TokenCount },
    .{ .name = "stzenginepolyglotclear", .func = ring_Clear },
};
