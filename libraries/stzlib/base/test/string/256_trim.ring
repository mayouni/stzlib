# Narrative
# --------
#
# NOTE (audit, 2026-07-05): DEFERRED -- RemoveWXTQ on lines -- the WXT retirement should migrate this to the W form, but Q(@item).IsMadeOfNumbers() as a RemoveWQ predicate over list items does not match (the list-item W-predicate path needs work). Engine/DSL backlog with 264/265.
# pr()
#
# Extracted from stzStringTest.ring, block #256.

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

? @@( o1.TrimQ().
	LinesQ().
	RemoveWXTQ("Q(@char).IsNumberInString()").
	Content()
)
#--> [ "ABCDEF", "GHIJKL", "MNOPQU", "RSTUVW" ]

pf()
# Executed in 0.12 second(s) in Ring 1.22
