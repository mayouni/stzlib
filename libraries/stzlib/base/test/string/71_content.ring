# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #71.
#ERR Error (R14) : Calling Method without definition: replacext

load "../../stzBase.ring"

pr()

	o1 = new stzString("ruby ring php")
	o1.ReplaceXT("ring", :AtPosition = 6, :By = "♥♥♥")

	? o1.Content()
	#--> "ruby ♥♥♥ php"

pf()
# Executed in 0.16 second(s)
