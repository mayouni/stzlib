//! Frequent-itemset counting for association rules, sizes 1 to 3.
//!
//! PHASE 5, SECOND PASS. The first pass took 200 transactions from 16.124s to 0.041s
//! by retiring the HasKey counting idiom, which was real and was not the end of it:
//! 5000 transactions still took 0.941s of counting that a hash table does in
//! microseconds. What remained was a `ring_find` LINEAR SCAN over a key list that
//! grows to every singleton, pair and triple in the data -- fine at 640 keys, not
//! fine at ten thousand. A scan was the right answer in Ring, where the alternative
//! was 479x worse; here the right answer is an actual hash.
//!
//! ITEMS ARE CODES, and the codes are assigned in strcmp order by the caller. That
//! matters more than it looks: Ring's `_Sorted` orders a transaction's items with
//! `strcmp` before building the key "a|b|c", so the key for {milk, bread} is
//! "bread|milk" whichever order they appeared in. Interning in strcmp order makes
//! code order the same order, so sorting integers here reproduces it exactly.
//!
//! INSERTION ORDER IS PART OF THE ANSWER. FrequentItemsets() returns its itemsets in
//! the order they were first counted, and that order is visible -- the library's own
//! test asserts that "bread" comes first. So the map below records the order keys
//! arrive in, and the generation order is Ring's to the loop nesting: for each item i
//! the singleton, then for each j > i the pair (i,j) followed by every triple
//! (i,j,k), then the next j, then the next i.
//!
//! DUPLICATE ITEMS WITHIN A TRANSACTION ARE NOT COLLAPSED, because Ring did not
//! collapse them: `_Sorted` copies and sorts without dedupe, so a basket listing
//! "milk" twice contributes a (milk, milk) pair. That is arguably wrong for
//! association rules and it is not this module's decision to make.

const std = @import("std");

/// A key is a size plus up to three codes, padded with -1. Fixed-size so it can go
/// straight into an AutoHashMap without a custom hasher.
pub const Key = [4]i32;

pub const Result = struct {
    /// keys in FIRST-COUNTED order
    keys: std.ArrayList(Key),
    /// counts, parallel to keys
    counts: std.ArrayList(u32),

    pub fn deinit(self: *Result, alloc: std.mem.Allocator) void {
        self.keys.deinit(alloc);
        self.counts.deinit(alloc);
    }
};

const Index = std.AutoHashMap(Key, u32);

inline fn key1(a: i32) Key {
    return .{ 1, a, -1, -1 };
}
inline fn key2(a: i32, b: i32) Key {
    return .{ 2, a, b, -1 };
}
inline fn key3(a: i32, b: i32, c: i32) Key {
    return .{ 3, a, b, c };
}

fn bump(res: *Result, idx: *Index, alloc: std.mem.Allocator, k: Key) !void {
    const gop = try idx.getOrPut(k);
    if (gop.found_existing) {
        res.counts.items[gop.value_ptr.*] += 1;
    } else {
        gop.value_ptr.* = @intCast(res.keys.items.len);
        try res.keys.append(alloc, k);
        try res.counts.append(alloc, 1);
    }
}

/// `items` holds every transaction's item codes back to back; transaction t occupies
/// items[offsets[t] .. offsets[t+1]]. `offsets` therefore has n_tx + 1 entries.
pub fn countAll(
    alloc: std.mem.Allocator,
    items: []const i32,
    offsets: []const u32,
    n_tx: usize,
) !Result {
    var res = Result{
        .keys = try std.ArrayList(Key).initCapacity(alloc, 0),
        .counts = try std.ArrayList(u32).initCapacity(alloc, 0),
    };
    errdefer res.deinit(alloc);

    var idx = Index.init(alloc);
    defer idx.deinit();

    // scratch for one sorted transaction
    var buf = try std.ArrayList(i32).initCapacity(alloc, 16);
    defer buf.deinit(alloc);

    var t: usize = 0;
    while (t < n_tx) : (t += 1) {
        const from = offsets[t];
        const to = offsets[t + 1];
        buf.clearRetainingCapacity();
        try buf.appendSlice(alloc, items[from..to]);
        // insertion sort, matching Ring's -- stable, and the sizes here are baskets
        const a = buf.items;
        var i: usize = 1;
        while (i < a.len) : (i += 1) {
            const e = a[i];
            var j: usize = i;
            while (j > 0 and a[j - 1] > e) : (j -= 1) a[j] = a[j - 1];
            a[j] = e;
        }

        // exactly Ring's nesting: single(i), then for each j>i the pair (i,j)
        // followed by every triple (i,j,k), then the next j, then the next i
        i = 0;
        while (i < a.len) : (i += 1) {
            try bump(&res, &idx, alloc, key1(a[i]));
            var j = i + 1;
            while (j < a.len) : (j += 1) {
                try bump(&res, &idx, alloc, key2(a[i], a[j]));
                var k = j + 1;
                while (k < a.len) : (k += 1) {
                    try bump(&res, &idx, alloc, key3(a[i], a[j], a[k]));
                }
            }
        }
    }
    return res;
}

// ─── tests ───────────────────────────────────────────────────────────────────

test "counts singletons, pairs and triples of one basket" {
    const alloc = std.testing.allocator;
    const items = [_]i32{ 0, 1, 2 };
    const offs = [_]u32{ 0, 3 };
    var r = try countAll(alloc, &items, &offs, 1);
    defer r.deinit(alloc);
    // 3 singles + 3 pairs + 1 triple
    try std.testing.expectEqual(@as(usize, 7), r.keys.items.len);
    for (r.counts.items) |c| try std.testing.expectEqual(@as(u32, 1), c);
}

test "insertion order is Ring's loop nesting" {
    const alloc = std.testing.allocator;
    const items = [_]i32{ 0, 1, 2 };
    const offs = [_]u32{ 0, 3 };
    var r = try countAll(alloc, &items, &offs, 1);
    defer r.deinit(alloc);
    // single(0), pair(0,1), triple(0,1,2), pair(0,2), single(1), pair(1,2), single(2)
    try std.testing.expectEqual(key1(0), r.keys.items[0]);
    try std.testing.expectEqual(key2(0, 1), r.keys.items[1]);
    try std.testing.expectEqual(key3(0, 1, 2), r.keys.items[2]);
    try std.testing.expectEqual(key2(0, 2), r.keys.items[3]);
    try std.testing.expectEqual(key1(1), r.keys.items[4]);
    try std.testing.expectEqual(key2(1, 2), r.keys.items[5]);
    try std.testing.expectEqual(key1(2), r.keys.items[6]);
}

test "a basket is sorted before its combinations are formed" {
    const alloc = std.testing.allocator;
    // the same set given in two orders must produce the same keys
    const a = [_]i32{ 2, 0, 1 };
    const b = [_]i32{ 1, 2, 0 };
    const offs = [_]u32{ 0, 3 };
    var ra = try countAll(alloc, &a, &offs, 1);
    defer ra.deinit(alloc);
    var rb = try countAll(alloc, &b, &offs, 1);
    defer rb.deinit(alloc);
    try std.testing.expectEqual(ra.keys.items.len, rb.keys.items.len);
    for (ra.keys.items, rb.keys.items) |ka, kb| try std.testing.expectEqual(ka, kb);
}

test "counts accumulate across transactions" {
    const alloc = std.testing.allocator;
    const items = [_]i32{ 0, 1, 0, 1, 0 };
    const offs = [_]u32{ 0, 2, 4, 5 };
    var r = try countAll(alloc, &items, &offs, 3);
    defer r.deinit(alloc);
    // item 0 appears in all three, the pair (0,1) in two
    try std.testing.expectEqual(key1(0), r.keys.items[0]);
    try std.testing.expectEqual(@as(u32, 3), r.counts.items[0]);
    try std.testing.expectEqual(key2(0, 1), r.keys.items[1]);
    try std.testing.expectEqual(@as(u32, 2), r.counts.items[1]);
}

test "a duplicated item is not collapsed -- Ring does not collapse it either" {
    const alloc = std.testing.allocator;
    const items = [_]i32{ 5, 5 };
    const offs = [_]u32{ 0, 2 };
    var r = try countAll(alloc, &items, &offs, 1);
    defer r.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), r.keys.items.len); // single(5), pair(5,5)
    try std.testing.expectEqual(@as(u32, 2), r.counts.items[0]); // counted twice
    try std.testing.expectEqual(key2(5, 5), r.keys.items[1]);
}
