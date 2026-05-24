const R = @import("ring_api.zig");
const mod = @import("polycode.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gl = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs = R.ring_vm_api_retstring2;

fn ring_Register(p: *anyopaque) callconv(.c) void {
    const concept = gs(p, 1);
    const con_len: usize = @intCast(gl(p, 1));
    const lang = gs(p, 2);
    const lang_len: usize = @intCast(gl(p, 2));
    const code = gs(p, 3);
    const code_len: usize = @intCast(gl(p, 3));
    rn(p, @floatFromInt(mod.stz_pc_register(concept, con_len, lang, lang_len, code, code_len)));
}

fn ring_GetCode(p: *anyopaque) callconv(.c) void {
    const concept = gs(p, 1);
    const con_len: usize = @intCast(gl(p, 1));
    const lang = gs(p, 2);
    const lang_len: usize = @intCast(gl(p, 2));
    var buf: [512]u8 = undefined;
    const len = mod.stz_pc_get_code(concept, con_len, lang, lang_len, &buf);
    if (len > 0) rs(p, &buf, @intCast(len)) else rs(p, @constCast(""), 0);
}

fn ring_HasConcept(p: *anyopaque) callconv(.c) void {
    const concept = gs(p, 1);
    const con_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_pc_has_concept(concept, con_len)));
}

fn ring_LangCount(p: *anyopaque) callconv(.c) void {
    const concept = gs(p, 1);
    const con_len: usize = @intCast(gl(p, 1));
    rn(p, @floatFromInt(mod.stz_pc_lang_count(concept, con_len)));
}

fn ring_ConceptCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(mod.stz_pc_concept_count()));
}

fn ring_Clear(p: *anyopaque) callconv(.c) void {
    _ = p;
    mod.stz_pc_clear();
}

pub const ring_funcs = [_]R.Reg{
    .{ .name = "stzenginepolycoderegister", .func = ring_Register },
    .{ .name = "stzenginepolycodegetcode", .func = ring_GetCode },
    .{ .name = "stzenginepolycodehasconcept", .func = ring_HasConcept },
    .{ .name = "stzenginepolycodelangcount", .func = ring_LangCount },
    .{ .name = "stzenginepolycodeconceptcount", .func = ring_ConceptCount },
    .{ .name = "stzenginepolycodeclear", .func = ring_Clear },
};
