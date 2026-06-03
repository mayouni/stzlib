# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #791.

load "../../stzBase.ring"

pr()

StzStringQ("Tunis is the town of my memories.") {
	ReplaceAllCS("TUNIS", "Niamey", :CS = FALSE )
	? Content()
}
#--> Niamey is the town of my memories

pf()
# Executed in 0.01 second(s).
