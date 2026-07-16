const ts = @import("tree_sitter.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;

// StzEnginePolyglotParse(cLang, cSource) -> the CLASS|/METHOD|/FUNC|/IMPORT|/
// CALL| line protocol (one record per line) for the Ring code-graph. cLang
// is "python" | "javascript". This is the forward API for any language.
fn ring_Parse(p: *anyopaque) callconv(.c) void {
    ts.parseLang(gs(p, 1), gss(p, 1), gs(p, 2), gss(p, 2));
    rs2(p, &ts.g_buf, @intCast(ts.g_len));
}

// StzEnginePolyglotParsePython(cSource) -- retained for compatibility.
fn ring_ParsePython(p: *anyopaque) callconv(.c) void {
    ts.parsePython(gs(p, 1), gss(p, 1));
    rs2(p, &ts.g_buf, @intCast(ts.g_len));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginepolyglotparse", .func = &ring_Parse },
    .{ .name = "stzenginepolyglotparsepython", .func = &ring_ParsePython },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
