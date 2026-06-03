# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #790.

load "../../stzBase.ring"


StzStringQ("Tunis is the town of my memories.") {
	ReplaceAll("Tunis", "Niamey" )
	? Content()
}
#--> Niamey is the town of my memories.

pf()
# Executed in 0.01 second(s).
