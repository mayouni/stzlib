// W3C Trace Context -- gap-analysis Tier 2.
//
// Distributed + agentic systems need to correlate a request as it hops
// across services. The W3C `traceparent` header carries:
//
//   00-<32 hex trace-id>-<16 hex span-id>-<2 hex flags>
//   version  trace-id (16B)   span-id (8B)   flags (01 = sampled)
//
// This module generates fresh contexts, derives child spans (same
// trace-id, new span-id) for outbound calls, validates incoming headers,
// and extracts the parts. Pure code -- no I/O, no dependencies.
//
//   tracectx_new(out, max)               -> a fresh sampled traceparent
//   tracectx_child(parent, out, max)     -> child of an incoming header
//   tracectx_is_valid(tp)                -> 1 / 0
//   tracectx_trace_id(tp, out, max)      -> 32-hex trace-id
//   tracectx_span_id(tp, out, max)       -> 16-hex span-id
//   tracectx_sampled(tp)                 -> 1 if the sampled flag is set

const std = @import("std");

const TP_LEN: usize = 55; // "00-" + 32 + "-" + 16 + "-" + 2

const Parsed = struct {
    tid: [16]u8,
    sid: [8]u8,
    flags: u8,
};

fn allZero(bytes: []const u8) bool {
    for (bytes) |b| if (b != 0) return false;
    return true;
}

fn parseTp(tp: []const u8) ?Parsed {
    var it = std.mem.splitScalar(u8, tp, '-');
    const ver = it.next() orelse return null;
    const tidh = it.next() orelse return null;
    const sidh = it.next() orelse return null;
    const flagh = it.next() orelse return null;
    if (it.next() != null) return null; // must be exactly 4 fields
    if (ver.len != 2 or tidh.len != 32 or sidh.len != 16 or flagh.len != 2) return null;
    if (std.mem.eql(u8, ver, "ff")) return null; // 'ff' is forbidden
    var p: Parsed = undefined;
    _ = std.fmt.hexToBytes(&p.tid, tidh) catch return null;
    _ = std.fmt.hexToBytes(&p.sid, sidh) catch return null;
    var fb: [1]u8 = undefined;
    _ = std.fmt.hexToBytes(&fb, flagh) catch return null;
    p.flags = fb[0];
    if (allZero(&p.tid) or allZero(&p.sid)) return null; // all-zero ids invalid
    return p;
}

fn formatTp(out: [*]u8, max: usize, tid: [16]u8, sid: [8]u8, flags: u8) i32 {
    if (max < TP_LEN) return -1;
    const tidhex = std.fmt.bytesToHex(tid, .lower);
    const sidhex = std.fmt.bytesToHex(sid, .lower);
    const flaghex = std.fmt.bytesToHex([_]u8{flags}, .lower);
    const s = std.fmt.bufPrint(out[0..max], "00-{s}-{s}-{s}", .{ tidhex, sidhex, flaghex }) catch return -1;
    return @intCast(s.len);
}

/// A fresh sampled traceparent (random trace-id + span-id).
pub fn tracectx_new(out: [*]u8, max: usize) callconv(.c) i32 {
    var tid: [16]u8 = undefined;
    var sid: [8]u8 = undefined;
    std.crypto.random.bytes(&tid);
    std.crypto.random.bytes(&sid);
    return formatTp(out, max, tid, sid, 0x01);
}

/// Child of an incoming traceparent: same trace-id + flags, new span-id.
/// Returns -1 if the parent header is invalid.
pub fn tracectx_child(parent_ptr: [*]const u8, parent_len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    const p = parseTp(parent_ptr[0..parent_len]) orelse return -1;
    var sid: [8]u8 = undefined;
    std.crypto.random.bytes(&sid);
    return formatTp(out, max, p.tid, sid, p.flags);
}

pub fn tracectx_is_valid(tp_ptr: [*]const u8, tp_len: usize) callconv(.c) i32 {
    return if (parseTp(tp_ptr[0..tp_len]) != null) 1 else 0;
}

pub fn tracectx_trace_id(tp_ptr: [*]const u8, tp_len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    const p = parseTp(tp_ptr[0..tp_len]) orelse return -1;
    if (max < 32) return -1;
    const hex = std.fmt.bytesToHex(p.tid, .lower);
    @memcpy(out[0..32], &hex);
    return 32;
}

pub fn tracectx_span_id(tp_ptr: [*]const u8, tp_len: usize, out: [*]u8, max: usize) callconv(.c) i32 {
    const p = parseTp(tp_ptr[0..tp_len]) orelse return -1;
    if (max < 16) return -1;
    const hex = std.fmt.bytesToHex(p.sid, .lower);
    @memcpy(out[0..16], &hex);
    return 16;
}

pub fn tracectx_sampled(tp_ptr: [*]const u8, tp_len: usize) callconv(.c) i32 {
    const p = parseTp(tp_ptr[0..tp_len]) orelse return -1;
    return if (p.flags & 0x01 != 0) 1 else 0;
}

// ── tests (pure -- part of the default sweep) ────────────────

test "tracectx: new is valid + well-formed + sampled" {
    var buf: [64]u8 = undefined;
    const n = tracectx_new(&buf, buf.len);
    try std.testing.expectEqual(@as(i32, 55), n);
    try std.testing.expectEqual(@as(i32, 1), tracectx_is_valid(&buf, @intCast(n)));
    try std.testing.expectEqual(@as(i32, 1), tracectx_sampled(&buf, @intCast(n)));
    try std.testing.expect(std.mem.startsWith(u8, buf[0..@intCast(n)], "00-"));
}

test "tracectx: child keeps trace-id, changes span-id" {
    var parent: [64]u8 = undefined;
    const pn: usize = @intCast(tracectx_new(&parent, parent.len));
    var child: [64]u8 = undefined;
    const cn = tracectx_child(&parent, pn, &child, child.len);
    try std.testing.expectEqual(@as(i32, 55), cn);

    var ptid: [40]u8 = undefined;
    var ctid: [40]u8 = undefined;
    _ = tracectx_trace_id(&parent, pn, &ptid, ptid.len);
    _ = tracectx_trace_id(&child, @intCast(cn), &ctid, ctid.len);
    try std.testing.expectEqualSlices(u8, ptid[0..32], ctid[0..32]); // same trace

    var psid: [40]u8 = undefined;
    var csid: [40]u8 = undefined;
    _ = tracectx_span_id(&parent, pn, &psid, psid.len);
    _ = tracectx_span_id(&child, @intCast(cn), &csid, csid.len);
    try std.testing.expect(!std.mem.eql(u8, psid[0..16], csid[0..16])); // new span
}

test "tracectx: malformed headers are rejected" {
    const bad = [_][]const u8{
        "garbage",
        "00-xyz-1111111111111111-01",
        "00-00000000000000000000000000000000-1111111111111111-01", // zero trace
        "00-abcdef-1111111111111111-01", // short trace-id
        "ff-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01", // ff version
    };
    for (bad) |b| try std.testing.expectEqual(@as(i32, 0), tracectx_is_valid(b.ptr, b.len));
}

test "tracectx: a known-good W3C example parses" {
    const tp = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01";
    try std.testing.expectEqual(@as(i32, 1), tracectx_is_valid(tp.ptr, tp.len));
    try std.testing.expectEqual(@as(i32, 1), tracectx_sampled(tp.ptr, tp.len));
    var tid: [40]u8 = undefined;
    _ = tracectx_trace_id(tp.ptr, tp.len, &tid, tid.len);
    try std.testing.expectEqualSlices(u8, "0af7651916cd43dd8448eb211c80319c", tid[0..32]);
}
