const ts = @import("tree_sitter.zig");
const R = @import("ring_api.zig");

const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rs2 = R.ring_vm_api_retstring2;

// StzEnginePolyglotParsePython(cSource) -> the CLASS|/METHOD|/FUNC|/IMPORT|/
// CALL| line protocol (one record per line) for the Ring code-graph to ingest.
fn ring_ParsePython(p: *anyopaque) callconv(.c) void {
    ts.parsePython(gs(p, 1), gss(p, 1));
    rs2(p, &ts.g_buf, @intCast(ts.g_len));
}

const regs = [_]R.Reg{
    .{ .name = "stzenginepolyglotparsepython", .func = &ring_ParsePython },
};

pub fn registerAll(state: *anyopaque) void {
    R.registerAll(state, &regs);
}
