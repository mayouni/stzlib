//! A11Y -- the accessibility tree, handed to the platform's own API.
//!
//! G4b of base/gui/SOFTANZA_GUI_PLAN.md. G4a built the tree; this hands it
//! to whatever the operating system uses to talk to a screen reader --
//! UI Automation on Windows, NSAccessibility on macOS, AT-SPI on Linux --
//! by way of AccessKit, which is the library that speaks all three.
//!
//! THE VENDORED DLL IS LOADED AT RUNTIME, NEVER LINKED, exactly as stz_gpu
//! does with wgpu_native. So stz_a11y.dll always loads, and a machine
//! without accesskit.dll simply has no screen-reader bridge -- a legitimate
//! state, reported honestly, the same way a machine without a GPU has no
//! 3D scene. See vendor/accesskit/VERSION for why a prebuilt binary is the
//! house's shape rather than a new kind of decision.
//!
//! WHAT CROSSES: one JSON string, the same one stzAccessibilityTree already
//! publishes. That is Rule 104 taken literally -- what a screen reader can
//! operate, an agent can operate, and both read the same document. It also
//! means the Ring side did not have to change to gain a platform bridge.
//!
//! TWO SHARP EDGES, both paid for here rather than by a caller:
//!
//!   THE ADAPTER PANICS IF THE WINDOW IS ALREADY VISIBLE. AccessKit's
//!   subclassing adapter must be created before the window is shown, and
//!   GLFW shows a window at birth. So the window is hidden, the adapter
//!   built, and the window shown again -- three calls, invisible in
//!   practice when done right after creation, and it keeps the constraint
//!   inside this module instead of reshaping the graphics plane's API.
//!
//!   THE ACTIVATION HANDLER RUNS WHEN AN AT FIRST CONNECTS, which may be
//!   long after the tree was pushed, and it must RETURN a tree. So the
//!   latest JSON is kept and a fresh accesskit tree is built on demand.
//!   A bridge that only answered pushes would be silent for any reader
//!   that started after the program did -- which is most of them.

const std = @import("std");
const builtin = @import("builtin");

const c = @cImport({
    if (builtin.os.tag == .windows) {
        @cDefine("_WIN32", "1");
        @cDefine("WIN32_LEAN_AND_MEAN", "1");
        @cInclude("windows.h");
    }
    @cInclude("accesskit.h");
});

const alloc = std.heap.c_allocator;

pub const OK: i64 = 0;
pub const BAD_ARG: i64 = -1;
pub const UNAVAILABLE: i64 = -2;
pub const REFUSED: i64 = -3;

// ------------------------------------------------------------ the runtime

/// Every AccessKit entry point this module uses, and no more. The struct
/// IS the dependency surface: if a version bump drops one, the load fails
/// by name at startup rather than by crash at first use.
const Fns = struct {
    accesskit_node_new: *const fn (u32) callconv(.c) ?*anyopaque,
    accesskit_node_free: *const fn (?*anyopaque) callconv(.c) void,
    accesskit_node_set_label: *const fn (?*anyopaque, [*:0]const u8) callconv(.c) void,
    accesskit_node_set_description: *const fn (?*anyopaque, [*:0]const u8) callconv(.c) void,
    accesskit_node_set_bounds: *const fn (?*anyopaque, Rect) callconv(.c) void,
    accesskit_node_push_child: *const fn (?*anyopaque, u64) callconv(.c) void,
    accesskit_node_add_action: *const fn (?*anyopaque, u32) callconv(.c) void,
    accesskit_tree_new: *const fn (u64) callconv(.c) ?*anyopaque,
    accesskit_tree_update_with_focus: *const fn (u64) callconv(.c) ?*anyopaque,
    accesskit_tree_update_with_capacity_and_focus: *const fn (usize, u64) callconv(.c) ?*anyopaque,
    accesskit_tree_update_push_node: *const fn (?*anyopaque, u64, ?*anyopaque) callconv(.c) void,
    accesskit_tree_update_set_tree: *const fn (?*anyopaque, ?*anyopaque) callconv(.c) void,
    accesskit_tree_update_free: *const fn (?*anyopaque) callconv(.c) void,
};

/// Windows-only entry points, resolved separately so a non-Windows build
/// of this module still loads the portable half.
const WinFns = struct {
    accesskit_windows_subclassing_adapter_new: *const fn (
        ?*anyopaque,
        ?*const fn (?*anyopaque) callconv(.c) ?*anyopaque,
        ?*anyopaque,
        ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) void,
        ?*anyopaque,
    ) callconv(.c) ?*anyopaque,
    accesskit_windows_subclassing_adapter_free: *const fn (?*anyopaque) callconv(.c) void,
    accesskit_windows_subclassing_adapter_update_if_active: *const fn (
        ?*anyopaque,
        ?*const fn (?*anyopaque) callconv(.c) ?*anyopaque,
        ?*anyopaque,
    ) callconv(.c) ?*anyopaque,
    accesskit_windows_queued_events_raise: *const fn (?*anyopaque) callconv(.c) void,
};

pub const Rect = extern struct { x0: f64, y0: f64, x1: f64, y1: f64 };

var fns: Fns = undefined;
var wfns: WinFns = undefined;
var lib: ?std.DynLib = null;
var available = false;

var err_buf: [512]u8 = @splat(0);
var err_len: usize = 0;

fn setErr(msg: []const u8) void {
    const n = @min(msg.len, err_buf.len);
    @memcpy(err_buf[0..n], msg[0..n]);
    err_len = n;
}

pub fn lastError() []const u8 {
    return err_buf[0..err_len];
}

/// Load the vendored runtime. Answers false rather than raising: a
/// machine with no accesskit.dll has no screen-reader bridge, and that is
/// a state to report, not an error to throw.
pub fn load(path: []const u8) bool {
    if (available) return true;
    var dl = std.DynLib.open(path) catch {
        setErr("accesskit.dll could not be opened at the given path");
        return false;
    };
    inline for (@typeInfo(Fns).@"struct".fields) |f| {
        @field(fns, f.name) = dl.lookup(f.type, f.name) orelse {
            setErr("accesskit.dll is missing an entry point this build needs");
            dl.close();
            return false;
        };
    }
    if (builtin.os.tag == .windows) {
        inline for (@typeInfo(WinFns).@"struct".fields) |f| {
            @field(wfns, f.name) = dl.lookup(f.type, f.name) orelse {
                setErr("accesskit.dll has no Windows adapter -- wrong build?");
                dl.close();
                return false;
            };
        }
    }
    lib = dl;
    available = true;
    return true;
}

pub fn isAvailable() bool {
    return available;
}

// ------------------------------------------------------- the role mapping
//
// OUR NINETEEN ROLES, mapped to AccessKit's. G4a chose the nineteen by
// checking them against BOTH the ARIA vocabulary and AccessKit's 182-role
// schema, so this table is the payoff for that check rather than a new
// negotiation. An unknown role becomes `group`, which is what a screen
// reader announces for a plain container -- never `unknown`, which would
// make a reader say nothing at all.

const RoleMap = struct { name: []const u8, role: u32 };

fn roleValue(name: []const u8) u32 {
    const T = struct {
        fn eq(a: []const u8, b: []const u8) bool {
            return std.mem.eql(u8, a, b);
        }
    };
    if (T.eq(name, "window")) return c.ACCESSKIT_ROLE_WINDOW;
    if (T.eq(name, "group")) return c.ACCESSKIT_ROLE_GROUP;
    if (T.eq(name, "button")) return c.ACCESSKIT_ROLE_BUTTON;
    if (T.eq(name, "link")) return c.ACCESSKIT_ROLE_LINK;
    if (T.eq(name, "heading")) return c.ACCESSKIT_ROLE_HEADING;
    // STATIC TEXT IS `paragraph`, and all three candidates were MEASURED
    // against a real UI Automation client rather than argued about. Our
    // `label` role means "a run of static text"; AccessKit has three
    // plausible homes for it and two of them lose the text, differently:
    //
    //   ACCESSKIT_ROLE_LABEL     the node appears as ControlType.Text and
    //                            its NAME IS EMPTY. AccessKit's Label is
    //                            the FORM-LABEL element -- the thing that
    //                            names another control -- so its text is
    //                            attributed elsewhere. Present and silent,
    //                            which is the worst of the three.
    //   ACCESSKIT_ROLE_TEXT_RUN  the nodes DISAPPEAR: the client's
    //                            descendant count fell from 11 to 7. A
    //                            text run is an internal text-position
    //                            node, not a control.
    //   ACCESSKIT_ROLE_PARAGRAPH visible, named, announced. Costs the
    //                            more informative ControlType.Text -- it
    //                            arrives as a named Group -- and a named
    //                            Group is read aloud where a nameless
    //                            Text is not.
    if (T.eq(name, "label")) return c.ACCESSKIT_ROLE_PARAGRAPH;
    if (T.eq(name, "textbox")) return c.ACCESSKIT_ROLE_TEXT_INPUT;
    if (T.eq(name, "checkbox")) return c.ACCESSKIT_ROLE_CHECK_BOX;
    if (T.eq(name, "radio")) return c.ACCESSKIT_ROLE_RADIO_BUTTON;
    if (T.eq(name, "list")) return c.ACCESSKIT_ROLE_LIST;
    if (T.eq(name, "listitem")) return c.ACCESSKIT_ROLE_LIST_ITEM;
    if (T.eq(name, "tab")) return c.ACCESSKIT_ROLE_TAB;
    if (T.eq(name, "tablist")) return c.ACCESSKIT_ROLE_TAB_LIST;
    if (T.eq(name, "toolbar")) return c.ACCESSKIT_ROLE_TOOLBAR;
    if (T.eq(name, "status")) return c.ACCESSKIT_ROLE_STATUS;
    if (T.eq(name, "dialog")) return c.ACCESSKIT_ROLE_DIALOG;
    if (T.eq(name, "image")) return c.ACCESSKIT_ROLE_IMAGE;
    if (T.eq(name, "separator")) return c.ACCESSKIT_ROLE_SPLITTER;
    if (T.eq(name, "paragraph")) return c.ACCESSKIT_ROLE_PARAGRAPH;
    if (T.eq(name, "text")) return c.ACCESSKIT_ROLE_TEXT_RUN;
    return c.ACCESSKIT_ROLE_GROUP;
}

fn actionValue(name: []const u8) ?u32 {
    if (std.mem.eql(u8, name, "focus")) return c.ACCESSKIT_ACTION_FOCUS;
    if (std.mem.eql(u8, name, "click")) return c.ACCESSKIT_ACTION_CLICK;
    return null;
}

// --------------------------------------------------------------- the tree
//
// Node ids are ASSIGNED, not hashed. A hash of the declaration name would
// be stable across runs but could collide, and a collision here merges two
// controls into one as far as a screen reader is concerned -- silently.
// Sequential ids in document order cannot collide, and the mapping is kept
// so focus can be named.

const Node = struct {
    id: u64,
    name: []const u8, // the declaration name, borrowed from the JSON copy
    role: u32,
    label: ?[]const u8,
    description: ?[]const u8,
    bounds: ?Rect,
    focusable: bool,
    focused: bool,
    actions: [4]u32,
    n_actions: usize,
    children: [][]const u8,
};

const Tree = struct {
    json: []u8, // owned; every slice below borrows from it
    parsed: std.json.Parsed(std.json.Value),
    nodes: []Node,

    fn deinit(self: *Tree) void {
        alloc.free(self.nodes);
        self.parsed.deinit();
        alloc.free(self.json);
    }

    fn idOf(self: *const Tree, nm: []const u8) ?u64 {
        for (self.nodes) |n| {
            if (std.mem.eql(u8, n.name, nm)) return n.id;
        }
        return null;
    }

    fn focusId(self: *const Tree) u64 {
        for (self.nodes) |n| {
            if (n.focused) return n.id;
        }
        // NO FOCUS IS NOT AN OPTION for AccessKit -- a tree must name a
        // focused node, and naming the root is what every toolkit does
        // when nothing inside has focus yet.
        return if (self.nodes.len > 0) self.nodes[0].id else 1;
    }
};

fn parseTree(json: []const u8) !Tree {
    const owned = try alloc.dupe(u8, json);
    errdefer alloc.free(owned);

    var parsed = try std.json.parseFromSlice(std.json.Value, alloc, owned, .{});
    errdefer parsed.deinit();

    const root = parsed.value.object.get("nodes") orelse return error.NoNodes;
    const arr = root.array;

    var nodes = try alloc.alloc(Node, arr.items.len);
    errdefer alloc.free(nodes);

    for (arr.items, 0..) |item, i| {
        const o = item.object;
        var n = Node{
            .id = @intCast(i + 1),
            .name = "",
            .role = c.ACCESSKIT_ROLE_GROUP,
            .label = null,
            .description = null,
            .bounds = null,
            .focusable = false,
            .focused = false,
            .actions = .{ 0, 0, 0, 0 },
            .n_actions = 0,
            .children = &.{},
        };
        if (o.get("id")) |v| n.name = v.string;
        if (o.get("role")) |v| n.role = roleValue(v.string);
        if (o.get("name")) |v| {
            if (v.string.len > 0) n.label = v.string;
        }
        if (o.get("description")) |v| {
            if (v.string.len > 0) n.description = v.string;
        }
        if (o.get("focusable")) |v| n.focusable = (v == .bool and v.bool);
        if (o.get("focused")) |v| n.focused = (v == .bool and v.bool);
        if (o.get("bounds")) |v| {
            // NULL bounds stay NULL. G4a's rule, and it survives the
            // crossing: a magnifier told a thing is at 0,0 goes there.
            if (v == .array and v.array.items.len == 4) {
                const b = v.array.items;
                const x = numOf(b[0]);
                const y = numOf(b[1]);
                const w = numOf(b[2]);
                const h = numOf(b[3]);
                n.bounds = .{ .x0 = x, .y0 = y, .x1 = x + w, .y1 = y + h };
            }
        }
        if (o.get("actions")) |v| {
            if (v == .array) {
                for (v.array.items) |a| {
                    if (a != .string) continue;
                    if (actionValue(a.string)) |av| {
                        if (n.n_actions < n.actions.len) {
                            n.actions[n.n_actions] = av;
                            n.n_actions += 1;
                        }
                    }
                }
            }
        }
        if (o.get("children")) |v| {
            if (v == .array and v.array.items.len > 0) {
                const kids = try alloc.alloc([]const u8, v.array.items.len);
                for (v.array.items, 0..) |k, j| kids[j] = k.string;
                n.children = kids;
            }
        }
        nodes[i] = n;
    }

    return .{ .json = owned, .parsed = parsed, .nodes = nodes };
}

fn numOf(v: std.json.Value) f64 {
    return switch (v) {
        .integer => |i| @floatFromInt(i),
        .float => |f| f,
        else => 0,
    };
}

// ------------------------------------------------------------- the adapter

const Adapter = struct {
    live: bool = false,
    gen: u32 = 0,
    handle: ?*anyopaque = null, // accesskit_windows_subclassing_adapter
    tree: ?Tree = null,
    updates: u64 = 0,
    activations: u64 = 0,
};

var adapters: std.ArrayListUnmanaged(Adapter) = .{};

fn slotOf(id: i64) ?usize {
    if (id <= 0) return null;
    const slot: usize = @intCast((id & 0xffff) - 1);
    if (slot >= adapters.items.len) return null;
    if (!adapters.items[slot].live) return null;
    const gen: u32 = @intCast(id >> 16);
    if (adapters.items[slot].gen != gen) return null;
    return slot;
}

fn makeId(slot: usize, gen: u32) i64 {
    return (@as(i64, gen) << 16) | @as(i64, @intCast(slot + 1));
}

/// Build a fresh accesskit tree_update from the stored tree. Called on
/// every push AND from the activation handler, because an AT that
/// connects late must be given the whole tree, not the next change.
fn buildUpdate(a: *Adapter) ?*anyopaque {
    const t = if (a.tree) |*tr| tr else return null;
    if (t.nodes.len == 0) return null;

    const upd = fns.accesskit_tree_update_with_capacity_and_focus(t.nodes.len, t.focusId()) orelse return null;

    for (t.nodes) |n| {
        const node = fns.accesskit_node_new(n.role) orelse continue;
        if (n.label) |s| {
            const z = alloc.dupeZ(u8, s) catch null;
            if (z) |zz| {
                fns.accesskit_node_set_label(node, zz.ptr);
                alloc.free(zz);
            }
        }
        if (n.description) |s| {
            const z = alloc.dupeZ(u8, s) catch null;
            if (z) |zz| {
                fns.accesskit_node_set_description(node, zz.ptr);
                alloc.free(zz);
            }
        }
        if (n.bounds) |b| fns.accesskit_node_set_bounds(node, b);
        for (n.children) |kid| {
            if (t.idOf(kid)) |kid_id| fns.accesskit_node_push_child(node, kid_id);
        }
        var k: usize = 0;
        while (k < n.n_actions) : (k += 1) fns.accesskit_node_add_action(node, n.actions[k]);
        // FOCUSABLE IS AN ACTION, not a flag, in AccessKit's model: a node
        // that supports Focus is one a reader can move to. G4a's law --
        // every focusable node has a role and a name -- is what makes that
        // safe to assert here.
        if (n.focusable) fns.accesskit_node_add_action(node, c.ACCESSKIT_ACTION_FOCUS);
        fns.accesskit_tree_update_push_node(upd, n.id, node);
    }

    const tree = fns.accesskit_tree_new(t.nodes[0].id);
    if (tree != null) fns.accesskit_tree_update_set_tree(upd, tree);
    return upd;
}

fn onActivate(userdata: ?*anyopaque) callconv(.c) ?*anyopaque {
    const a: *Adapter = @ptrCast(@alignCast(userdata orelse return null));
    a.activations += 1;
    return buildUpdate(a);
}

fn onAction(_: ?*anyopaque, _: ?*anyopaque) callconv(.c) void {
    // A READER CAN ASK FOR THINGS, and this does not yet route them back
    // into the panel. Counting them would be a lie about capability, so
    // the request is dropped and the plan says so: activating a control
    // FROM a screen reader is not delivered in G4b.
}

/// Attach to a native window. See the header for why it is hidden first.
pub fn attach(hwnd_bits: u64) i64 {
    if (!available) return UNAVAILABLE;
    if (hwnd_bits == 0) return BAD_ARG;
    if (builtin.os.tag != .windows) return UNAVAILABLE;

    var slot: usize = adapters.items.len;
    for (adapters.items, 0..) |s, i| {
        if (!s.live) {
            slot = i;
            break;
        }
    }
    if (slot == adapters.items.len) {
        adapters.append(alloc, .{}) catch return REFUSED;
    }
    const a = &adapters.items[slot];
    a.* = .{ .live = true, .gen = a.gen +% 1 };

    const hwnd: ?*anyopaque = @ptrFromInt(@as(usize, @intCast(hwnd_bits)));

    // THE VISIBILITY DANCE. AccessKit's subclassing adapter panics on a
    // visible window, and GLFW shows a window at birth. Hide, build, show.
    var user32 = std.DynLib.open("user32.dll") catch null;
    var show: ?*const fn (?*anyopaque, i32) callconv(.c) i32 = null;
    if (user32) |*u32lib| {
        show = u32lib.lookup(*const fn (?*anyopaque, i32) callconv(.c) i32, "ShowWindow");
    }
    if (show) |f| _ = f(hwnd, 0); // SW_HIDE

    a.handle = wfns.accesskit_windows_subclassing_adapter_new(
        hwnd,
        onActivate,
        @ptrCast(a),
        onAction,
        null,
    );

    if (show) |f| _ = f(hwnd, 5); // SW_SHOW

    if (a.handle == null) {
        a.live = false;
        setErr("AccessKit refused the window handle");
        return REFUSED;
    }
    return makeId(slot, a.gen);
}

/// Hand over a tree, as the JSON stzAccessibilityTree already publishes.
pub fn update(id: i64, json: []const u8) i64 {
    const slot = slotOf(id) orelse return BAD_ARG;
    const a = &adapters.items[slot];

    var t = parseTree(json) catch {
        setErr("the tree JSON did not parse");
        return BAD_ARG;
    };
    // AN EMPTY TREE IS REFUSED, not published. It parses perfectly well,
    // and publishing it would REPLACE a good tree with nothing -- a
    // window that had been fully described going silent, with no error
    // anywhere. A window always has at least a root, so an empty node
    // list is a caller's bug rather than a legitimate state, and the
    // previous tree is left exactly where it was.
    if (t.nodes.len == 0) {
        t.deinit();
        setErr("the tree carried no nodes -- refused rather than published");
        return BAD_ARG;
    }
    if (a.tree) |*old| old.deinit();
    a.tree = t;

    if (builtin.os.tag == .windows) {
        const ev = wfns.accesskit_windows_subclassing_adapter_update_if_active(
            a.handle,
            onActivate,
            @ptrCast(a),
        );
        // NOT ACTIVE IS NOT A FAILURE: no screen reader is running, so
        // nothing needs raising. The tree is stored either way, which is
        // what lets a reader that starts later be given everything.
        if (ev != null) wfns.accesskit_windows_queued_events_raise(ev);
    }
    a.updates += 1;
    return OK;
}

pub fn detach(id: i64) i64 {
    const slot = slotOf(id) orelse return BAD_ARG;
    const a = &adapters.items[slot];
    if (builtin.os.tag == .windows and a.handle != null) {
        wfns.accesskit_windows_subclassing_adapter_free(a.handle);
    }
    a.handle = null;
    if (a.tree) |*t| t.deinit();
    a.tree = null;
    a.live = false;
    return OK;
}

/// [ updates, activations, nodes ] -- what the bridge has actually done,
/// so a caller can tell "pushed a tree" from "a reader read it".
pub fn stats(id: i64, out: *[3]f64) i64 {
    const slot = slotOf(id) orelse return BAD_ARG;
    const a = &adapters.items[slot];
    out[0] = @floatFromInt(a.updates);
    out[1] = @floatFromInt(a.activations);
    out[2] = @floatFromInt(if (a.tree) |t| t.nodes.len else 0);
    return OK;
}

pub fn isLive(id: i64) bool {
    return slotOf(id) != null;
}
