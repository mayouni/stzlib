# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #779.

load "../../stzBase.ring"


o1 = new stzString("oooo Tunisia---")
o1 {
	ReplaceLeadingChar("o", :With = "Hi")
	? Content()
	#--> Hi Tunisia---

	ReplaceTrailingChar("-", :With = "!")
	? Content()
	#--> Hi Tunisia!
}

pf()
# Executed in 0.02 second(s).
