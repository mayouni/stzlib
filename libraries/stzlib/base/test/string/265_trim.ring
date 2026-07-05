# Narrative
# --------
#
# NOTE (audit, 2026-07-05): DEFERRED -- RemoveWXTQ over lines -- same list-item W-predicate gap as 256/264. Engine/DSL backlog.
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #265.

load "../../stzBase.ring"

pr()

o1 = new stzString("

ABCDEF
GHIJKL
123346
MNOPQU
RSTUVW
984332

")

? o1.TrimQ().LinesQ().RemoveWXTQ(' Q(@line).IsMadeOfNumbers() ').Content()

#-->
# "ABCDEF
#  GHIJKL
#  MNOPQU
#  RSTUVW"

StopProfiler()

pf()
# Executed in 0.09 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.19
