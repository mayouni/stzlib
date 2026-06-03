# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #777.
#ERR Error (R3) : Calling Function without definition: replaceeachleadingchar

load "../../stzBase.ring"

pr()

o1 = new stzString("aaaaah Tunisia!---")
o1 {
	ReplaceEachLeadingChar(:With = "O")
	? Content()
	#--> OOOOOh Tunisia!---

	ReplaceEachTrailingChar(:With = "")
	? Content()
	#--> OOOOOh Tunisia!
}

pf()
# Executed in 0.02 second(s).
