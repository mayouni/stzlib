// Ring Extension Bridge for stz_meta
//
// Exposes the Softanza Meta-Engine to Ring via FFI.
// Ring calls these functions by name after ringlib_init registers them.
//
// Functions exposed:
//   stz_meta_init()                          -- initialize engine + register all data
//   stz_meta_shutdown()                      -- free resources
//   stz_meta_is_named_param(keyword)         -- check named param registry (O(1))
//   stz_meta_is_one_of_named_params(kw, n)   -- check multiple keywords
//   stz_meta_param_check_enabled()           -- query toggle
//   stz_meta_set_param_check(bool)           -- set toggle
//   stz_meta_format_error(code, ...)         -- format error from catalog
//   stz_meta_register_alias(class, alias, canonical)
//   stz_meta_resolve_alias(class, method)    -- resolve alias -> canonical
//   stz_meta_alias_count(class)              -- count aliases for class
//   stz_meta_gen_rule_count(class)           -- count generation rules
//   stz_meta_gen_rule_get(class, index)      -- get rule at index (kind, generated, canonical)
//   stz_meta_history_enabled()               -- query history toggle
//   stz_meta_set_history(bool)               -- set history toggle

const std = @import("std");
const R = @import("ring_api.zig");
const meta = @import("meta.zig");
const named_params = @import("named_params.zig");
const error_catalog = @import("error_catalog.zig");
const method_gen = @import("method_gen.zig");

var _rules: ?method_gen.RuleSet = null;

// ─── Lifecycle ───

fn ring_MetaInit(p: *anyopaque) callconv(.c) void {
    _ = p;
    const eng = meta.engine();

    named_params.registerAll(eng) catch return;
    error_catalog.registerAll(eng) catch return;

    _rules = method_gen.RuleSet.init(eng.allocator);
    method_gen.registerStzListRules(&_rules.?) catch return;
}

fn ring_MetaShutdown(p: *anyopaque) callconv(.c) void {
    _ = p;
    if (_rules) |*rs| {
        rs.deinit();
        _rules = null;
    }
    meta.shutdown();
}

// ─── Named Param Registry ───

fn ring_IsNamedParam(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) < 1 or R.ring_vm_api_isstring(p, 1) == 0) {
        R.ring_vm_api_retnumber(p, 0);
        return;
    }
    const ptr = R.ring_vm_api_getstring(p, 1);
    const len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const keyword = ptr[0..len];

    const eng = meta.engine();
    const result: f64 = if (eng.isNamedParam(keyword)) 1 else 0;
    R.ring_vm_api_retnumber(p, result);
}

// ─── Param Check Toggle ───

fn ring_ParamCheckEnabled(p: *anyopaque) callconv(.c) void {
    const eng = meta.engine();
    R.ring_vm_api_retnumber(p, if (eng.param_check_enabled) 1 else 0);
}

fn ring_SetParamCheck(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) < 1 or R.ring_vm_api_isnumber(p, 1) == 0) return;
    const val = R.ring_vm_api_getnumber(p, 1);
    const eng = meta.engine();
    eng.param_check_enabled = (val != 0);
}

// ─── Error Formatting ───

fn ring_FormatError(p: *anyopaque) callconv(.c) void {
    const argc = R.ring_vm_api_paracount(p);
    if (argc < 1 or R.ring_vm_api_isstring(p, 1) == 0) {
        R.ring_vm_api_retstring(p, "Error: missing error code");
        return;
    }

    const code_ptr = R.ring_vm_api_getstring(p, 1);
    const code_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const code = code_ptr[0..code_len];

    // Build substitution pairs from remaining args (key, value, key, value, ...)
    var subs: [16]meta.Substitution = undefined;
    var sub_count: usize = 0;
    var i: c_int = 2;
    while (i + 1 <= argc and sub_count < 16) : (i += 2) {
        if (R.ring_vm_api_isstring(p, i) == 0 or R.ring_vm_api_isstring(p, i + 1) == 0) break;
        const k_ptr = R.ring_vm_api_getstring(p, i);
        const k_len: usize = @intCast(R.ring_vm_api_getstringsize(p, i));
        const v_ptr = R.ring_vm_api_getstring(p, i + 1);
        const v_len: usize = @intCast(R.ring_vm_api_getstringsize(p, i + 1));
        subs[sub_count] = .{ .key = k_ptr[0..k_len], .value = v_ptr[0..v_len] };
        sub_count += 1;
    }

    const eng = meta.engine();
    var buf: [1024]u8 = undefined;
    if (eng.formatError(code, subs[0..sub_count], &buf)) |len| {
        R.ring_vm_api_retstring2(p, &buf, @intCast(len));
    } else {
        R.ring_vm_api_retstring(p, "Unknown error code");
    }
}

// ─── Alias Engine ───

fn ring_RegisterAlias(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) < 3) return;
    if (R.ring_vm_api_isstring(p, 1) == 0 or
        R.ring_vm_api_isstring(p, 2) == 0 or
        R.ring_vm_api_isstring(p, 3) == 0) return;

    const cls_ptr = R.ring_vm_api_getstring(p, 1);
    const cls_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const alias_ptr = R.ring_vm_api_getstring(p, 2);
    const alias_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 2));
    const canon_ptr = R.ring_vm_api_getstring(p, 3);
    const canon_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 3));

    const eng = meta.engine();
    const table = eng.getOrCreateAliasTable(cls_ptr[0..cls_len]) catch return;
    table.register(alias_ptr[0..alias_len], canon_ptr[0..canon_len]) catch return;
}

fn ring_ResolveAlias(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) < 2) {
        R.ring_vm_api_retstring(p, "");
        return;
    }
    if (R.ring_vm_api_isstring(p, 1) == 0 or R.ring_vm_api_isstring(p, 2) == 0) {
        R.ring_vm_api_retstring(p, "");
        return;
    }

    const cls_ptr = R.ring_vm_api_getstring(p, 1);
    const cls_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const meth_ptr = R.ring_vm_api_getstring(p, 2);
    const meth_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 2));

    const eng = meta.engine();
    if (eng.resolveAlias(cls_ptr[0..cls_len], meth_ptr[0..meth_len])) |canonical| {
        R.ring_vm_api_retstring2(p, canonical.ptr, @intCast(canonical.len));
    } else {
        R.ring_vm_api_retstring(p, "");
    }
}

fn ring_AliasCount(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) < 1 or R.ring_vm_api_isstring(p, 1) == 0) {
        R.ring_vm_api_retnumber(p, 0);
        return;
    }
    const cls_ptr = R.ring_vm_api_getstring(p, 1);
    const cls_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));

    const eng = meta.engine();
    const table = eng.aliases.get(cls_ptr[0..cls_len]);
    if (table) |t| {
        R.ring_vm_api_retnumber(p, @floatFromInt(t.count()));
    } else {
        R.ring_vm_api_retnumber(p, 0);
    }
}

// ─── Method Generation Rules ───

fn ring_GenRuleCount(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) < 1 or R.ring_vm_api_isstring(p, 1) == 0) {
        R.ring_vm_api_retnumber(p, 0);
        return;
    }
    const cls_ptr = R.ring_vm_api_getstring(p, 1);
    const cls_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));

    if (_rules) |*rs| {
        const rules = rs.rulesForClass(cls_ptr[0..cls_len]);
        R.ring_vm_api_retnumber(p, @floatFromInt(rules.len));
    } else {
        R.ring_vm_api_retnumber(p, 0);
    }
}

fn ring_GenRuleGet(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) < 2) {
        R.ring_vm_api_retstring(p, "");
        return;
    }
    if (R.ring_vm_api_isstring(p, 1) == 0 or R.ring_vm_api_isnumber(p, 2) == 0) {
        R.ring_vm_api_retstring(p, "");
        return;
    }

    const cls_ptr = R.ring_vm_api_getstring(p, 1);
    const cls_len: usize = @intCast(R.ring_vm_api_getstringsize(p, 1));
    const idx: usize = @intFromFloat(R.ring_vm_api_getnumber(p, 2));

    if (_rules) |*rs| {
        const rules = rs.rulesForClass(cls_ptr[0..cls_len]);
        if (idx < 1 or idx > rules.len) {
            R.ring_vm_api_retstring(p, "");
            return;
        }
        const rule = rules[idx - 1];

        // Return as "kind|generated|canonical" pipe-delimited string
        var buf: [512]u8 = undefined;
        const kind_str: []const u8 = switch (rule.kind) {
            .cs => "cs",
            .fluent_q => "fluent_q",
            .passive => "passive",
        };
        const written = std.fmt.bufPrint(&buf, "{s}|{s}|{s}", .{
            kind_str, rule.generated, rule.canonical,
        }) catch {
            R.ring_vm_api_retstring(p, "");
            return;
        };
        R.ring_vm_api_retstring2(p, &buf, @intCast(written.len));
    } else {
        R.ring_vm_api_retstring(p, "");
    }
}

// ─── History Toggle ───

fn ring_HistoryEnabled(p: *anyopaque) callconv(.c) void {
    const eng = meta.engine();
    R.ring_vm_api_retnumber(p, if (eng.history_enabled) 1 else 0);
}

fn ring_SetHistory(p: *anyopaque) callconv(.c) void {
    if (R.ring_vm_api_paracount(p) < 1 or R.ring_vm_api_isnumber(p, 1) == 0) return;
    const val = R.ring_vm_api_getnumber(p, 1);
    const eng = meta.engine();
    eng.history_enabled = (val != 0);
}

// ─── Registration Table ───

pub const registrations = [_]R.Reg{
    .{ .name = "stz_meta_init", .func = &ring_MetaInit },
    .{ .name = "stz_meta_shutdown", .func = &ring_MetaShutdown },
    .{ .name = "stz_meta_is_named_param", .func = &ring_IsNamedParam },
    .{ .name = "stz_meta_param_check_enabled", .func = &ring_ParamCheckEnabled },
    .{ .name = "stz_meta_set_param_check", .func = &ring_SetParamCheck },
    .{ .name = "stz_meta_format_error", .func = &ring_FormatError },
    .{ .name = "stz_meta_register_alias", .func = &ring_RegisterAlias },
    .{ .name = "stz_meta_resolve_alias", .func = &ring_ResolveAlias },
    .{ .name = "stz_meta_alias_count", .func = &ring_AliasCount },
    .{ .name = "stz_meta_gen_rule_count", .func = &ring_GenRuleCount },
    .{ .name = "stz_meta_gen_rule_get", .func = &ring_GenRuleGet },
    .{ .name = "stz_meta_history_enabled", .func = &ring_HistoryEnabled },
    .{ .name = "stz_meta_set_history", .func = &ring_SetHistory },
};
