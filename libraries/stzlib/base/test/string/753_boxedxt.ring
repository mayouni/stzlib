# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #753.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Center
])
#-->
# ╭────────────────────╮
# │ PARIS              │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Left
])
#-->
# ╭────────────────────╮
# │       PARIS        │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Right
])
#-->
# ╭────────────────────╮
# │ P    A   R   I   S │
# ╰────────────────────╯

? StzStringQ("PARIS").BoxedXT([
	:AllCorners = :Round,
	:Width = 20,
	:TextAdjustedTo = :Justified
])
#-->
# ╭────────────────────╮
# │              PARIS │
# ╰────────────────────╯

pf()
# Executed in 0.05 second(s) in Ring 1.23
