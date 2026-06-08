---
name: grind-err
description: Systematically reduce stzlib #ERR count for a topic directory. Use when the user says "grind <topic>", "continue grind", "grind string", "reduce ERR", or asks to keep burning down test failures in a stzlib topic.
---

# Grind ERR

A repeatable loop for reducing `#ERR`-tagged test failures in
`libraries/stzlib/base/test/<topic>/`. The point of the skill is
discipline -- the same checks every time so a stray duplicate def
or arity collision doesn't masquerade as a regression.

## When to invoke

- "grind string", "grind char", "grind <topic>"
- "continue the grind", "keep going on path 1"
- "reduce ERR count", "burn down failures"
- After landing a fix, when the user says "continue"

## The loop (one iteration)

### 1. Baseline

```bash
TOPIC=string  # or char, dataset, etc.
DIR=libraries/stzlib/base/test/$TOPIC

# live count of files carrying #ERR headers
grep -l '^#ERR' $DIR/*.ring | wc -l

# error-type distribution (the leverage map)
grep -h '^#ERR' $DIR/*.ring | sort | uniq -c | sort -rn | head -10
```

### 2. Pick the highest-leverage cluster

Order of preference:
1. **Common root cause across many tests** (e.g. one primitive fix
   unlocked the entire UTF-8 cluster — 19 tests in one commit).
2. **Named-param dispatcher pattern** (`:With/:By/:Of/:StartingAt`
   unwraps) — usually 5–10 tests share the same fix shape.
3. **Symbolic-position resolution** (`:First/:Last/:LastChar`) —
   `_ResolveSymPos` in stzString already exists; extend its callers.
4. **Per-method aliases** — last resort, marginal returns.

Skip:
- Standalone diagnostic tests (`test_checker.ring`, `test_core.ring`)
  that load the engine themselves — pre-existing, not part of the grind.
- C27 syntax errors in test files — usually pre-existing.

### 3. Survey the cluster

```bash
# for the chosen error type, find call sites
for f in $(grep -l "^#ERR Error (R??)" $DIR/*.ring | head -10); do
    n=$(ring "$f" 2>&1 | grep "in file $(basename $f)" | grep -oE "line [0-9]+" | head -1 | awk '{print $2}')
    echo "$f L$n: $(sed -n "${n}p" "$f")"
done
```

Note: run from inside `$DIR` so relative `../../stzBase.ring` resolves.

### 4. Apply the fix

Edit the offending method(s) in `libraries/stzlib/base/string/stzString.ring`
(or stzList, stzStringFunc, etc.).

**Before saving the final edit, mentally check:**
- Is the new method name unique case-insensitively? (Ring quirk)
- Does the signature break any existing caller? `grep -rn "\.MethodName(" libraries/stzlib/base/`
- Are operator precedences right? `_aRes_ + (x + y - 1)` not `_aRes_ + x + y - 1`

### 5. Syntax-check immediately

```bash
echo 'load "libraries/stzlib/base/string/stzString.ring"' > /tmp/loadcheck.ring
ring /tmp/loadcheck.ring 2>&1 | grep -iE "stzString|error " | head -3
```

If C22 fires, find the dup with:
```bash
grep -niE "^\s*def\s+<methodname>\s*\(" libraries/stzlib/base/string/stzString.ring
```

### 6. Spot-verify

```bash
cd libraries/stzlib/base/test/$TOPIC
for t in <list of cluster tests>; do
    echo "$t : $(ring "$t" 2>&1 | grep -E 'STOPPED|Error|panic' | head -1 | head -c 90)"
done
```

`STOPPED!` = pass. Anything else = still failing.

### 7. Commit + push both remotes

```bash
git add libraries/stzlib/base/string/stzString.ring  # be specific, not -A
git commit -m "string: <one-line cluster description>

<body with what was fixed and any caveats>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"

git push origin main
git push codeberg main  # ok to fail; codeberg auth expires
```

### 8. Re-annotate in background

```bash
python _annotate_test_errors.py $TOPIC
# ~25 minutes; run with run_in_background:true and continue working
```

### 9. Confirm strict decrease

When the background task completes, check the totals tail and the
live count. If ERR went UP, something I introduced is wrong —
search for case-insensitive duplicate defs first.

## Iteration cadence

One cluster per commit. Don't batch multiple unrelated clusters
into a single commit — if one regresses, the others are stuck with
it. Small commits = trivial revert.

## Reporting back

After each iteration, give the user a one-line update:

> Cluster X (Y tests) — fixed Z. ERR floor: A → B. Annotate
> running in background.

Don't propose options for the next cluster — pick the highest-leverage
one and start. The user can interrupt.

## Constraints carried from CLAUDE.md

- Use Softanza engine helpers, not Ring's `substr` byte-ops.
- All test loops must be compile-time bounded.
- No non-ASCII in console output.
- Never use `for X in list` iterator form.
- Hoist `ring_len()` out of `for` loops.
- Push to both origin and codeberg.
- Never create PRs; merge directly to main.
