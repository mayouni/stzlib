const embed = @import("embed.zig");
const R = @import("ring_api.zig");

const gn = R.ring_vm_api_getnumber;
const gs = R.ring_vm_api_getstring;
const gss = R.ring_vm_api_getstringsize;
const rn = R.ring_vm_api_retnumber;
const rs2 = R.ring_vm_api_retstring2;

fn ring_VersionMajor(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.embed_version_major()));
}

fn ring_VersionMinor(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.embed_version_minor()));
}

fn ring_VersionPatch(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.embed_version_patch()));
}

fn ring_VersionString(p: *anyopaque) callconv(.c) void {
    var buf: [32]u8 = undefined;
    const len = embed.embed_version_string(&buf, 32);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_BuildOs(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = embed.embed_build_os(&buf, 64);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_BuildArch(p: *anyopaque) callconv(.c) void {
    var buf: [64]u8 = undefined;
    const len = embed.embed_build_arch(&buf, 64);
    if (len > 0) rs2(p, &buf, @intCast(len)) else rs2(p, &buf, 0);
}

fn ring_RegisterFeature(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    const enabled: i32 = @intFromFloat(gn(p, 2));
    rn(p, @floatFromInt(embed.embed_register_feature(ptr, len, enabled)));
}

fn ring_HasFeature(p: *anyopaque) callconv(.c) void {
    const ptr: [*]const u8 = @ptrCast(gs(p, 1));
    const len: usize = @intCast(gss(p, 1));
    rn(p, @floatFromInt(embed.embed_has_feature(ptr, len)));
}

fn ring_FeatureCount(p: *anyopaque) callconv(.c) void {
    rn(p, @floatFromInt(embed.embed_feature_count()));
}

fn ring_ClearFeatures(p: *anyopaque) callconv(.c) void {
    _ = p;
    embed.embed_clear_features();
}

pub const regs = [_]R.Reg{
    .{ .name = "stzengineembedversionmajor", .func = &ring_VersionMajor },
    .{ .name = "stzengineembedversionminor", .func = &ring_VersionMinor },
    .{ .name = "stzengineembedversionpatch", .func = &ring_VersionPatch },
    .{ .name = "stzengineembedversionstring", .func = &ring_VersionString },
    .{ .name = "stzengineembedbuildos", .func = &ring_BuildOs },
    .{ .name = "stzengineembedbuildarch", .func = &ring_BuildArch },
    .{ .name = "stzengineembedregisterfeature", .func = &ring_RegisterFeature },
    .{ .name = "stzengineembedhasfeature", .func = &ring_HasFeature },
    .{ .name = "stzengineembedfeaturecount", .func = &ring_FeatureCount },
    .{ .name = "stzengineembedclearfeatures", .func = &ring_ClearFeatures },
};

pub fn registerAll(pState: *anyopaque) void {
    R.registerAll(pState, &regs);
}
