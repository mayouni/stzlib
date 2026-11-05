#!/usr/bin/env python3
"""The digest of every vendored library -- SOFTANZA_ONE_HOUR.md, B1 (W0).

Each folder under engine/vendor carries a VERSION file and, until today, no digest:
a changed file in curl or mbedtls looked exactly like the one we chose. This tool
writes engine/vendor/DIGESTS -- one line per library: name, version, the number of
files, and one SHA-256 over the whole tree (every file's path and bytes, in sorted
order) -- and checks a tree against it the way the models are checked against
SHA256SUMS: a mismatch is refused, by exit code.

    python engine/tools/vendor_digest.py --write            record the tree as it is
    python engine/tools/vendor_digest.py --check            exit = number of libraries that differ
    python engine/tools/vendor_digest.py --check --root D   another vendor folder (fixtures)
    python engine/tools/vendor_digest.py --selftest         a fixture tree, tampered, is refused

The record is data for stzExposure (base/security/stzExposure.ring), which reads
DIGESTS and reports each library with its digest and the time of the last check.
Writing a new record is the act that moves a pin: do it on purpose, and say so in
the commit.
"""
import hashlib, os, sys, time, tempfile, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_ROOT = os.path.normpath(os.path.join(HERE, '..', 'vendor'))
RECORD = 'DIGESTS'
SKIP_DIRS = {'.zig-cache', 'zig-out', '__pycache__', '.git'}


def tree_digest(folder):
    """One SHA-256 over every file's relative path and bytes, sorted."""
    h = hashlib.sha256()
    n = 0
    for dp, dn, fn in os.walk(folder):
        dn[:] = sorted(d for d in dn if d not in SKIP_DIRS)
        for f in sorted(fn):
            p = os.path.join(dp, f)
            rel = os.path.relpath(p, folder).replace(os.sep, '/')
            h.update(rel.encode('utf-8') + b'\0')
            with open(p, 'rb') as fh:
                for chunk in iter(lambda: fh.read(1 << 20), b''):
                    h.update(chunk)
            h.update(b'\0')
            n += 1
    return h.hexdigest(), n


def version_of(folder):
    for name in ('VERSION', 'VERSION.txt', 'VERSION.md'):
        p = os.path.join(folder, name)
        if os.path.isfile(p):
            with open(p, encoding='utf-8', errors='replace') as fh:
                return fh.readline().strip() or 'unknown'
    return 'unknown'


def scan(root):
    rows = []
    for name in sorted(os.listdir(root)):
        folder = os.path.join(root, name)
        if not os.path.isdir(folder) or name in SKIP_DIRS:
            continue
        digest, n = tree_digest(folder)
        rows.append((name, version_of(folder), n, digest))
    return rows


def write(root, rows):
    stamp = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    with open(os.path.join(root, RECORD), 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('# engine/vendor/DIGESTS -- written by engine/tools/vendor_digest.py --write\n')
        fh.write('# name | version | files | sha256 of the tree (sorted paths and bytes)\n')
        fh.write('# recorded: %s\n' % stamp)
        for name, ver, n, d in rows:
            fh.write('%s | %s | %d | %s\n' % (name, ver, n, d))


def read(root):
    p = os.path.join(root, RECORD)
    if not os.path.isfile(p):
        return None
    rows = {}
    with open(p, encoding='utf-8') as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            name, ver, n, d = [x.strip() for x in line.split('|')]
            rows[name] = (ver, int(n), d)
    return rows


def check(root, quiet=False):
    recorded = read(root)
    if recorded is None:
        print('NO RECORD: %s has no %s -- run --write first' % (root, RECORD))
        return 1
    bad = 0
    for name, ver, n, d in scan(root):
        r = recorded.get(name)
        if r is None:
            print('  UNRECORDED  %s (%s, %d files)' % (name, ver, n)); bad += 1
        elif r[2] != d:
            print('  CHANGED     %s: %d files now, %d recorded' % (name, n, r[1])); bad += 1
        elif not quiet:
            print('  ok          %s %s' % (name, ver))
        if r is not None:
            recorded.pop(name)
    for name in recorded:
        print('  MISSING     %s' % name); bad += 1
    print('vendored libraries differing from the record: %d' % bad)
    return bad


def selftest():
    tmp = tempfile.mkdtemp(prefix='vendor_digest_')
    try:
        lib = os.path.join(tmp, 'tinylib'); os.makedirs(os.path.join(lib, 'src'))
        open(os.path.join(lib, 'VERSION'), 'w').write('tinylib 1.0\n')
        open(os.path.join(lib, 'src', 'a.c'), 'w').write('int a(void){return 1;}\n')
        write(tmp, scan(tmp))
        clean = check(tmp, quiet=True)
        open(os.path.join(lib, 'src', 'a.c'), 'a').write('/* one byte more */')
        tampered = check(tmp, quiet=True)
        shutil.copy(os.path.join(lib, 'VERSION'), os.path.join(lib, 'src', 'b.c'))
        added = check(tmp, quiet=True)
        print('selftest: clean=%d tampered=%d added=%d' % (clean, tampered, added))
        return 0 if (clean, tampered, added) == (0, 1, 1) else 1
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main(argv):
    root = DEFAULT_ROOT
    if '--root' in argv:
        root = argv[argv.index('--root') + 1]
    if '--selftest' in argv:
        return selftest()
    if '--write' in argv:
        rows = scan(root)
        write(root, rows)
        for name, ver, n, d in rows:
            print('  %-12s %-40s %5d files  %s' % (name, ver[:40], n, d[:16]))
        print('recorded %d libraries in %s' % (len(rows), os.path.join(root, RECORD)))
        return 0
    return check(root, quiet='--quiet' in argv)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
