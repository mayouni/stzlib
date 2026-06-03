# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #901.

load "../../stzBase.ring"


o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxedXT([
	[ "line", "thin" ],
	[ "eachchar", 1 ],
	[ "allcorners", "" ],
	[ "corners", "" ]
])
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

pf()
# Executed in 0.04 second(s).
