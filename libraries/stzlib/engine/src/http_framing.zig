// HTTP/1.1 request/response framing over a raw byte buffer.
//
// This parses ATTACKER-CONTROLLED bytes on every server connection (and the
// TLS client's response), so it is the reactor's most-exposed untrusted-input
// surface. Extracted into its own module so the SAME code the server runs can
// be hammered directly by the fuzz harness (src/fuzz_http.zig). Pure slice
// logic -- no allocation, no globals -- so a fuzzer only needs Zig's runtime
// safety (bounds/overflow) to surface a memory bug.

const std = @import("std");

/// Total byte length of the first complete HTTP message in `bytes` (headers
/// through "\r\n\r\n" plus a Content-Length body), or null if incomplete.
/// Must never read out of bounds regardless of how malformed `bytes` is.
pub fn httpRequestLen(bytes: []const u8) ?usize {
    const he = std.mem.indexOf(u8, bytes, "\r\n\r\n") orelse return null;
    const header_end = he + 4;
    const clen = httpContentLength(bytes[0..header_end]);
    // header_end + clen can overflow usize on a hostile Content-Length; use a
    // widening/overflow-safe check so a huge declared length just reads as
    // "not yet complete" instead of wrapping.
    const need = @addWithOverflow(header_end, clen);
    if (need[1] != 0) return null; // overflowed -> cannot have that many bytes
    if (bytes.len >= need[0]) return need[0];
    return null;
}

/// Content-Length value from a header block, or 0 if absent/unparsable.
pub fn httpContentLength(headers: []const u8) usize {
    var it = std.mem.splitSequence(u8, headers, "\r\n");
    _ = it.next(); // request/status line
    while (it.next()) |line| {
        if (line.len == 0) break;
        const colon = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        if (std.ascii.eqlIgnoreCase(std.mem.trim(u8, line[0..colon], " \t"), "content-length")) {
            const v = std.mem.trim(u8, line[colon + 1 ..], " \t");
            return std.fmt.parseInt(usize, v, 10) catch 0;
        }
    }
    return 0;
}
