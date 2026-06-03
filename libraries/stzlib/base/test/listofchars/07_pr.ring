# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #7.

load "../../stzBase.ring"


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
