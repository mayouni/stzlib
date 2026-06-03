# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #183.

load "../../stzBase.ring"


o1 = new stzString("/♥♥♥\__/\/\__/♥♥♥\__")

? o1.FindBetweenAsSections("♥♥♥", "/", "\")	# FindXT( "♥", :Between = ["/","\"], :AsSections )
#--> [ [2, 4], [15, 17] ]

? o1.FindAsSectionsXT( "♥♥♥", :Between = ["/","\"])
#--> [ [2, 4], [15, 17] ]

StopProfiler()
# Executed in 0.02 second(s)
