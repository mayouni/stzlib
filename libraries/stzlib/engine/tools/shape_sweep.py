#!/usr/bin/env python3
"""The autumn's two Zig bug shapes, swept over the engine -- SOFTANZA_ONE_HOUR.md B3 (W2a).

rnxc check reads Ring; nothing reads our Zig for the shapes that cost Linux a 9.8
and a local root this autumn. This sweep is narrow on purpose and prints its
number on every run, so a rule whose first run finds nothing is still a rule
whose mechanism is explained:

  moved-then-freed   CVE-2026-98432's shape. In one function body, a pointer
                     field is handed to a second owner (`a.p = b.p`, the same
                     field name on both sides, no dupe/clone/copy on the line),
                     and the first owner is then freed or destroyed in the same
                     body (`free(b`, `destroy(b`, `b.deinit(`). Two owners, one
                     object, one free: the second reads freed memory unless a
                     generation or a copy stands between them.
  const-cast-write   Copy Fail's shape. A read-only slice made writable
                     (`@constCast(`) is a zero-copy path through a boundary; the
                     rule asks that the line, or the three above it, NAME the
                     boundary ("boundary", "read-only", "why") -- a cast nobody
                     explained is the one nobody checked.

    python engine/tools/shape_sweep.py [src-dir]     exits with the number of findings
    python engine/tools/shape_sweep.py --selftest     the planted shapes are found, the
                                                      clean ones left alone

Static, by function body, over engine/src/*.zig (vendor/ is C and is not read).
A finding is a place to READ, not a verdict: the handle table's generations
(R16) are exactly the kind of fix this rule cannot see.
"""
import os, re, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_SRC = os.path.normpath(os.path.join(HERE, '..', 'src'))

fn_re = re.compile(r'^\s*(pub\s+)?(export\s+)?fn\s+([A-Za-z_]\w*)\s*\(')
move_re = re.compile(r'^\s*([A-Za-z_]\w*)\.([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)\.\2\s*;')
copy_words = ('dupe', 'clone', 'copy', 'alloc', 'retain', 'ref(')
cast_re = re.compile(r'@constCast\s*\(')
named = re.compile(r'boundary|read-only|readonly|why', re.I)


def bodies(lines):
    """(name, start, end) per fn, by brace depth from the fn line."""
    out, i, n = [], 0, len(lines)
    while i < n:
        m = fn_re.match(lines[i])
        if not m:
            i += 1; continue
        name, start, depth, opened = m.group(3), i, 0, False
        j = i
        while j < n:
            depth += lines[j].count('{') - lines[j].count('}')
            if '{' in lines[j]: opened = True
            if opened and depth <= 0: break
            j += 1
        out.append((name, start, j)); i = j + 1
    return out


def sweep_file(path, lines):
    findings = []
    for name, a, b in bodies(lines):
        body = lines[a:b + 1]
        for k, l in enumerate(body):
            if l.strip().startswith('//'): continue
            m = move_re.match(l)
            if m and not any(w in l for w in copy_words):
                src = m.group(3)
                rest = '\n'.join(body[k + 1:])
                if re.search(r'\b(free|destroy)\s*\(\s*' + re.escape(src) + r'\b', rest) or \
                   re.search(r'\b' + re.escape(src) + r'\.deinit\s*\(', rest):
                    findings.append(('moved-then-freed', path, a + k + 1, name,
                                     f'{m.group(1)}.{m.group(2)} takes {src}.{m.group(2)}, then {src} is freed in this body'))
            if cast_re.search(l):
                ctx = '\n'.join(body[max(0, k - 3):k + 1])
                if not named.search(ctx):
                    findings.append(('const-cast-write', path, a + k + 1, name,
                                     '@constCast with no named boundary within three lines'))
    return findings


def sweep(src):
    findings, nfiles = [], 0
    for dp, dn, fn in os.walk(src):
        dn[:] = [d for d in dn if d not in ('.zig-cache', 'zig-out')]
        for f in sorted(fn):
            if not f.endswith('.zig'): continue
            p = os.path.join(dp, f); nfiles += 1
            with open(p, encoding='utf-8', errors='replace') as fh:
                findings += sweep_file(os.path.relpath(p, src), fh.read().split('\n'))
    return findings, nfiles


PLANTED = '''
const std = @import("std");
const Opt = struct { p: ?*u8 };
fn moved(a: *Opt, b: *Opt, alloc: std.mem.Allocator) void {
    a.p = b.p;
    alloc.destroy(b);
}
fn copied(a: *Opt, b: *Opt, alloc: std.mem.Allocator) !void {
    a.p = try alloc.dupe(u8, b.p);
    alloc.destroy(b);
}
fn kept(a: *Opt, b: *Opt) void {
    a.p = b.p;
}
fn cast_unnamed(s: []const u8) []u8 {
    return @constCast(s);
}
fn cast_named(s: []const u8) []u8 {
    // boundary: s is the caller's scratch, writable by contract
    return @constCast(s);
}
'''


def selftest():
    d = tempfile.mkdtemp(prefix='shape_sweep_')
    with open(os.path.join(d, 'planted.zig'), 'w') as fh: fh.write(PLANTED)
    f, _ = sweep(d)
    rules = sorted(x[0] + ':' + x[3] for x in f)
    want = ['const-cast-write:cast_unnamed', 'moved-then-freed:moved']
    print('selftest:', rules, 'want', want)
    return 0 if rules == want else 1


def main(argv):
    if '--selftest' in argv: return selftest()
    src = argv[0] if argv and not argv[0].startswith('--') else DEFAULT_SRC
    f, nfiles = sweep(src)
    for rule, path, line, fn, msg in f:
        print(f'  {rule:18} {path}:{line}  {fn}  -- {msg}')
    print(f'shape sweep over {nfiles} Zig files: {len(f)} findings '
          f'({sum(1 for x in f if x[0] == "moved-then-freed")} moved-then-freed, '
          f'{sum(1 for x in f if x[0] == "const-cast-write")} const-cast-write)')
    return len(f)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
