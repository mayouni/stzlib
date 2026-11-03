"""THE ATELIER'S CHECKS, harvested from Softanza's own narrated suites.

    python harvest.py [--tests=<folder>]      default: ../base/test, beside this folder

A narrated suite states each assertion as `Then("description", <actual>, <expected>)` and judges it with
`=` (base/test/_narrated.ring). Every such line whose two expressions stand on their own -- no variable the
scenario set up before it, nothing that reads the clock, a file, the network or a device, nothing that
evaluates text or defines a lambda -- becomes a check the Atelier runs live: admitted with `func Run`,
called, released (POST /atelier/run). A helper the file defines and the check calls (ListEq has several
versions across the suites; Chr0xE9 lives in the string suite) is copied from that file into the check's
code, transitively, so the check runs with the helper its author wrote. The expected value is the
author's, never ours.

Writes checks.json beside this file: {source, commit, taken, files, thens, checks: [{id, domain, file,
line, scenario, desc, code}]}, `code` being the snippet /atelier/run admits. `source` is the tests folder
relative to the library (never a folder of this machine); `commit` is the checkout's HEAD when git answers.
Read-only on the test tree.
"""
import json, os, re, subprocess, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
TESTS = os.path.normpath(os.path.join(HERE, '..', 'base', 'test'))
for a in sys.argv[1:]:
    if a.startswith('--tests='):
        TESTS = os.path.abspath(a.split('=', 1)[1])

IDENT = re.compile(r'[A-Za-z_@$][A-Za-z0-9_@$]*')
ALLOWED = {'true', 'false', 'null', 'nl', 'tab', 'cr', 'and', 'or', 'not', 'new'}
# what a check must not do: read the clock or chance, touch the file system, the network, a process or a device,
# evaluate text, or define code that could outlive the run (a lambda)
BANNED = re.compile(r'random|clock|\btime\(|\bdate\(|now\(|sleep|system|\bread\(|\bwrite\(|remove\(|file|folder|'
                    r'\bdir\(|eval\(|\bfunc\b|http|socket|reactor|spawn|process|neural|gpu|window|gui|sound|voice|'
                    r'audio|download|url|network|port\b|thread|timer|elapsed|duration|stopwatch|tempname|getenv|sysget',
                    re.I)

# a string naming a file of the test suite: its data folder, or a file by its extension
SUITE_FILE = re.compile(r"""["'`][^"'`]*(_data/|t_edu|\.(pdf|zknw|csv|json|txt|xml|html?|png|svg|jpe?g|db|sqlite|wav|mp3|gguf|md|ring|stz[a-z]*)\b)[^"'`]*["'`]""", re.I)


def tokens(s):
    """Ring's tokens enough to tell code from text: (kind, text, start). Strings are '...', "..." or `...`,
    no escapes; `#` and `//` start a comment."""
    i, n = 0, len(s)
    while i < n:
        c = s[i]
        if c in '"\'`':
            j = s.find(c, i + 1)
            if j < 0:
                yield ('bad', s[i:], i)
                return
            yield ('str', s[i:j + 1], i)
            i = j + 1
        elif c == '#' or s.startswith('//', i):
            yield ('comment', s[i:], i)
            return
        elif c.isalpha() or c in '_@$':
            m = IDENT.match(s, i)
            yield ('id', m.group(0), i)
            i = m.end()
        elif c.isdigit():
            j = i
            while j < n and (s[j].isalnum() or s[j] == '.'):
                j += 1
            yield ('num', s[i:j], i)
            i = j
        elif c.isspace():
            i += 1
        else:
            yield ('op', c, i)
            i += 1


def then_args(line):
    """The arguments of a one-line `Then(...)`, split at its top-level commas, or None."""
    m = re.match(r'\s*Then\s*\(', line)
    if not m:
        return None
    depth, args, cur_start, end = 1, [], m.end(), None
    for kind, text, pos in tokens(line[m.end():]):
        pos += m.end()
        if kind == 'bad':
            return None
        if kind == 'comment':
            break
        if kind != 'op':
            continue
        if text in '([{':
            depth += 1
        elif text in ')]}':
            depth -= 1
            if depth == 0:
                args.append(line[cur_start:pos].strip())
                end = pos
                break
        elif text == ',' and depth == 1:
            args.append(line[cur_start:pos].strip())
            cur_start = pos + 1
    if end is None:
        return None
    rest = line[end + 1:].strip()
    if rest and not rest.startswith('#') and not rest.startswith('//'):
        return None
    return args


def calls_and_free(expr):
    """The functions an expression calls, and its free names (a variable it did not make)."""
    calls, free = set(), set()
    toks = list(tokens(expr))
    for k, (kind, text, pos) in enumerate(toks):
        if kind == 'bad':
            free.add('?')
            continue
        if kind != 'id':
            continue
        prev = toks[k - 1] if k else None
        nxt = toks[k + 1] if k + 1 < len(toks) else None
        if prev and prev[0] == 'op' and prev[1] in '.:':
            continue                                    # a method, or a :symbol
        if prev and prev[0] == 'id' and prev[1].lower() == 'new':
            continue                                    # a class name
        if nxt and nxt[0] == 'op' and nxt[1] == '(':
            calls.add(text.lower())
            continue
        if text.lower() in ALLOWED:
            continue
        free.add(text)
    return calls, free


def functions_of(lines):
    """name -> (source, the functions it calls), for every `func` the file defines."""
    out = {}
    i = 0
    while i < len(lines):
        m = re.match(r'(func|def)\s+([A-Za-z_@$][A-Za-z0-9_@$]*)', lines[i])
        if not m:
            i += 1
            continue
        j = i + 1
        while j < len(lines):
            s = lines[j]
            if re.match(r'(func|def|class)\s', s) or re.match(r'(Scenario|Then|Given|When|EndScenario|Summary|load)\b', s):
                break
            j += 1
        body = lines[i:j]
        while body and not body[-1].strip():
            body.pop()
        calls = set()
        for b in body[1:]:
            c, _ = calls_and_free(b)
            calls |= c
        out[m.group(2).lower()] = ('\n'.join(body), calls)
        i = j
    return out


def commit_of(folder):
    """The HEAD of the checkout holding `folder`, as git names it, or 'unknown'."""
    try:
        r = subprocess.run(['git', '-C', folder, 'log', '-1', '--format=%h'], capture_output=True, text=True, timeout=30)
        return r.stdout.strip() or 'unknown'
    except (OSError, subprocess.SubprocessError):
        return 'unknown'


def main():
    checks, seen = [], set()
    files = scanned = kept = 0
    why = {}
    for root, dirs, names in os.walk(TESTS):
        dirs[:] = sorted(d for d in dirs if not d.startswith('_'))
        for nm in sorted(names):
            if not nm.endswith('.ring') or nm.startswith('_'):
                continue
            p = os.path.join(root, nm)
            text = open(p, encoding='utf-8', errors='replace').read().replace('\r\n', '\n')
            if '_narrated.ring' not in text:
                continue
            files += 1
            lines = text.split('\n')
            helpers = functions_of(lines)
            scenario = ''
            for ln, line in enumerate(lines, 1):
                ms = re.match(r'\s*Scenario\s*\(\s*(["\'`])(.*)\1\s*\)', line)
                if ms:
                    scenario = ms.group(2)
                    continue
                if not re.match(r'\s*Then\s*\(', line):
                    continue
                scanned += 1
                args = then_args(line)
                if not args or len(args) != 3 or args[0][:1] not in '"\'`':
                    why['not one line of three arguments'] = why.get('not one line of three arguments', 0) + 1
                    continue
                desc, actual, expected = args[0][1:-1], args[1], args[2]
                if SUITE_FILE.search(actual) or SUITE_FILE.search(expected):
                    k = 'opens a file of the suite (an install carries the library without the suites)'
                    why[k] = why.get(k, 0) + 1
                    continue
                if BANNED.search(actual) or BANNED.search(expected):
                    why['reads the clock, a file, a device or evaluates text'] = why.get('reads the clock, a file, a device or evaluates text', 0) + 1
                    continue
                c1, f1 = calls_and_free(actual)
                c2, f2 = calls_and_free(expected)
                if f1 | f2:
                    why['uses a variable the scenario set up'] = why.get('uses a variable the scenario set up', 0) + 1
                    continue
                # the file's own helpers it reaches, transitively, in the order the file defines them
                need, todo = set(), list((c1 | c2) & set(helpers))
                while todo:
                    h = todo.pop()
                    if h in need:
                        continue
                    need.add(h)
                    todo.extend(helpers[h][1] & set(helpers))
                if any(BANNED.search(helpers[h][0]) for h in need):
                    why['its helper reads the clock, a file or a device'] = why.get('its helper reads the clock, a file or a device', 0) + 1
                    continue
                key = (actual, expected, tuple(sorted(helpers[h][0] for h in need)))
                if key in seen:
                    why['the same check again'] = why.get('the same check again', 0) + 1
                    continue
                seen.add(key)
                code = 'func Run cInput\n\treturn AtelierThen(' + actual + ', ' + expected + ')\n'
                for h in [h for h in helpers if h in need]:
                    code += '\n' + helpers[h][0] + '\n'
                rel = os.path.relpath(p, TESTS).replace(os.sep, '/')
                checks.append({'id': len(checks) + 1, 'domain': rel.split('/')[0], 'file': rel, 'line': ln,
                               'scenario': scenario, 'desc': desc, 'code': code})
                kept += 1
    out = os.path.join(HERE, 'checks.json')
    library = os.path.normpath(os.path.join(TESTS, '..', '..'))
    source = os.path.relpath(TESTS, library).replace(os.sep, '/') if os.path.isdir(library) else os.path.basename(TESTS)
    json.dump({'source': source, 'commit': commit_of(TESTS), 'taken': time.strftime('%Y-%m-%d %H:%M'),
               'files': files, 'thens': scanned, 'checks': checks},
              open(out, 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=0)
    print('%d narrated files, %d Then lines, %d checks kept (%d domains)' % (files, scanned, kept, len({c['domain'] for c in checks})))
    for k, v in sorted(why.items(), key=lambda x: -x[1]):
        print('   left out %6d  %s' % (v, k))
    print('wrote', out)


main()
