# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #7.
#ERR Error (R14) : Calling Method without definition: boxedxt

load "../../stzBase.ring"

pr()

? StzListOfCharsQ("A":"E").BoxedXT([
	:AllCorners = :Round,
	:Hilighted = [ 1, 2, 5, 3, 7 ],
	:Numbered = TRUE
])
#-->
# ╭───┬───┬───┬───┬───╮
# │ A │ B │ C │ D │ E │
# ╰───┴─•─┴─•─┴───┴─•─╯
#   1   2   3       5 

pf()
# Executed in 0.09 second(s).
