#ERR Error (R24) : Using uninitialized variable: ﻿load
﻿load "../stzBase.ring"

? "=== Strict Equality Test ==="

o1 = new stzList(["C", "A", "B"])

if o1.IsEqualTo(["A", "B", "C"])
    ? "  PASS: IsEqualTo (unordered)"
else
    ? "  FAIL: IsEqualTo (unordered)"
ok

if NOT o1.IsEqualToXT(["A", "B", "C"])
    ? "  PASS: IsEqualToXT different order = FALSE"
else
    ? "  FAIL: IsEqualToXT should be FALSE for different order"
ok

if o1.IsEqualToXT(["C", "A", "B"])
    ? "  PASS: IsEqualToXT same order = TRUE"
else
    ? "  FAIL: IsEqualToXT same order should be TRUE"
ok

if o1.IsStrictlyEqualTo(["C", "A", "B"])
    ? "  PASS: IsStrictlyEqualTo"
else
    ? "  FAIL: IsStrictlyEqualTo"
ok

if o1.IsIdenticalTo(["C", "A", "B"])
    ? "  PASS: IsIdenticalTo"
else
    ? "  FAIL: IsIdenticalTo"
ok

? ""
? "=== DONE ==="
