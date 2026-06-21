# Narrative
# --------
# ToCode() round-trips a stzList back into the exact Ring source-code
# literal that would reconstruct it.
#
# Unlike a plain display, ToCode() preserves type and quoting so the
# result is paste-ready Ring: the number 10 stays bare, the string
# containing embedded double-quotes is wrapped in single quotes, and
# the comma-bearing string keeps its surrounding double-quotes. This is
# the canonical Softanza way to capture a live list as reproducible code
# for tests, snapshots, or persistence.
#
# Extracted from stzlisttest.ring, block #236.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 10, '"[ :Tunis, :Paris ]"', "ONE," ])
? o1.ToCode()
#-- [ 10, '"[ :Tunis, :Paris ]"', "ONE," ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in ring 1.17
