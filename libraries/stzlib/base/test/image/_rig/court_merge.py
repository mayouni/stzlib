"""The default gate: build the court files shipped with the library from the courts the guards saved, and PROVE each count belongs to its measurement.

    python -I court_merge.py <base dir: libraries/stzlib/base> <test tree base dir, where the guards ran>

For every shipped faculty and golden set (the measurement files the library loads: image/vision.zmdl.txt, ocr/ocr.zmdl.txt) it takes the gains and
losses of every ordered pair of implementations from the guards' saved courts, and checks them against the shipped scores: on the same n items,
(gains - losses) / n MUST equal score(a) - score(b), within the precision the two scores were written with (0.88 is 0.875 to two decimals).
When the two were measured on different items (MP0: one could not run some here), the whole-set counts must be the sum of the per-language ones. A pair that fails is evidence of a different measurement and stops the merge. The incumbents
already declared in the shipped file are kept; the verdicts are not written as evidence (the library derives them on load).
"""
import glob
import os
import sys
from fractions import Fraction


def read_rows(path):
    rows = []
    for l in open(path, encoding="utf-8"):
        l = l.strip()
        if not l or l.startswith("#"):
            continue
        rows.append(l.split("|"))
    return rows


def _half_unit(text):
    """half a unit of the last decimal a score was WRITTEN with: 0.88 -> 0.005, 0.444 -> 0.0005, 0.787500 -> 0.0000005"""
    t = text.strip()
    d = len(t.split(".")[1]) if "." in t else 0
    return 0.5 * 10 ** (-d)


def measurements(path):
    m = {}
    for r in read_rows(path):
        if len(r) >= 6:
            m[(r[0], r[2], r[1])] = (float(r[3]), int(float(r[4])), _half_unit(r[3]))
    return m


def main(base, tree):
    plans = [(base + "/image/vision.zmdl.txt", base + "/image/vision.court.txt", glob.glob(tree + "/test/image/results/court_*.txt")),
             (base + "/ocr/ocr.zmdl.txt", base + "/ocr/ocr.court.txt", [tree + "/test/ocr/results/ocr.court.txt"])]
    for zpath, cpath, sources in plans:
        meas = measurements(zpath)
        keys = {(f, g) for (f, g, i) in meas}
        old = read_rows(cpath) if os.path.exists(cpath) else []
        incumbents = [r for r in old if r[0] == "incumbent"]
        counts = {}
        for r in old:
            if r[0] != "incumbent" and len(r) >= 6:
                counts[(r[0], r[1], r[2], r[3])] = (int(r[4]), int(r[5]), "shipped")
        for src in sorted(sources, key=os.path.getmtime):
            if not os.path.exists(src):
                print("MISSING:", src)
                continue
            for r in read_rows(src):
                if r[0] == "incumbent" or len(r) < 6:
                    continue
                f, g, a, b = r[0], r[1], r[2], r[3]
                if (f, g) in keys:
                    counts[(f, g, a, b)] = (int(float(r[4])), int(float(r[5])), os.path.basename(src))
        bad = 0
        checked = 0
        for (f, g, a, b), (gn, ls, src) in sorted(counts.items()):
            ma, mb = meas.get((f, g, a)), meas.get((f, g, b))
            if not ma or not mb:
                continue
            n = ma[1]
            if ma[1] != mb[1]:
                # MP0: measured on DIFFERENT items (one could not run some of them here), so the whole-set scores cannot predict the counts;
                # the court compared them on the items both could run -- which must be the sum of their per-language pairs
                sg = sl = 0
                langs = 0
                for (ff, gg, aa, bb), (g2, l2, _s) in counts.items():
                    if ff == f and aa == a and bb == b and gg.startswith(g + "/") and (f, gg, a) in meas and (f, gg, b) in meas:
                        sg += g2
                        sl += l2
                        langs += 1
                checked += 1
                if langs == 0 or (sg, sl) != (gn, ls):
                    bad += 1
                    print("MISMATCH %s %s %s over %s: measured on different items, and the counts %d/%d are not the sum of the per-language ones (%d/%d over %d languages)  [%s]" % (f, g, a, b, gn, ls, sg, sl, langs, src))
                continue
            lhs = Fraction(gn - ls, n)
            rhs = Fraction(ma[0]).limit_denominator(100000) - Fraction(mb[0]).limit_denominator(100000)
            checked += 1
            # the shipped scores were written to a few decimals: the count must agree within the precision they carry
            if abs(float(lhs - rhs)) > ma[2] + mb[2] + 1e-9:
                bad += 1
                print("MISMATCH %s %s %s over %s: (%d - %d) / %d = %.6f, scores differ by %.6f  [%s]" % (f, g, a, b, gn, ls, n, float(lhs), float(rhs), src))
        print("%s: %d pairs checked against the shipped scores, %d mismatched" % (os.path.basename(cpath), checked, bad))
        missing = []
        for (f, g) in sorted(keys):
            impls = sorted({i for (ff, gg, i) in meas if ff == f and gg == g})
            for a in impls:
                for b in impls:
                    if a != b and (f, g, a, b) not in counts:
                        missing.append("%s|%s|%s|%s" % (f, g, a, b))
        print("   ordered pairs with no evidence: %d%s" % (len(missing), (" -- " + ", ".join(missing[:12])) if missing else ""))
        if bad:
            print("   NOT WRITTEN: a count that does not belong to its measurement is not evidence")
            continue
        lines = ["# zcourt 1 -- the court's evidence per faculty and golden set (SOFTANZA_WEIGHT_SPACE_GOVERNANCE.md section 8; the default gate)",
                 "# faculty|golden|challenger|other|gains|losses   -- recomputed into a verdict on load: upheld when gains > losses and",
                 "# P(X >= gains | gains + losses, 1/2) <= 0.05. Every count was checked by _rig/court_merge.py: (gains - losses) / n = score(a) - score(b)",
                 "# incumbent|faculty|golden|impl   -- who holds the faculty when the court sits; the burden is on every other implementation"]
        lines += ["|".join(r) for r in incumbents]
        lines += ["%s|%s|%s|%s|%d|%d" % (f, g, a, b, gn, ls) for (f, g, a, b), (gn, ls, src) in sorted(counts.items())]
        open(cpath, "w", encoding="utf-8", newline="\r\n").write("\n".join(lines) + "\n")
        print("   written:", cpath, "|", len(counts), "counts,", len(incumbents), "incumbents")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
