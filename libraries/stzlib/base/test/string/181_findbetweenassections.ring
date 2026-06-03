# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #181.

load "../../stzBase.ring"

pr()

o1 = new stzString("/♥♥♥\__/\/\__/♥♥♥\__")
? o1.FindBetweenAsSections("♥♥♥", "/", "\")	# FindXT( "♥", :Between = ["/","\"], :AsSections )
#--> [ [2, 4], [15, 17] ]

? o1.FindAsSectionsXT( "♥♥♥", :Between = ["/","\"])
#--> [ [2, 4], [15, 17] ]

StopProfiler()

pf()
# Executed in 0.02 second(s)
