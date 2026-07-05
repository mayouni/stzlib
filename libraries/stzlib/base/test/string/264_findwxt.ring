# Narrative
# --------
#
# NOTE (audit, 2026-07-05): DEFERRED -- FindWXT is retired and its W replacement (FindW with a Q(@item).Method() predicate over list items) returns [] instead of [3,6] -- the list-item W-predicate evaluation needs work. Engine/DSL backlog with 256/265.
# pr()
#
# Extracted from stzStringTest.ring, block #264.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"ABCDEF",
	"GHIJKL",
	"123346",
	"MNOPQU",
	"RSTUVW",
	"984332"
])

? o1.FindWXT(' @IsNumberInString(@item) ')
#--> [ 3, 6 ]

pf()
# Executed in 0.13 second(s) in Ring 1.22
