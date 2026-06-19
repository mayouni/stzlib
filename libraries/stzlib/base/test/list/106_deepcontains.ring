# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #106.
#ERR Error (R14) : Calling Method without definition: deepfind

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"1",
	"🌞",
	"1",
	[ "2", "🌞", "2", "🌞"],
	"1",
	[ "2", ["3", "🌞"] ]
])

? o1.DeepContains("🌞")
#--> TRUE

? @@( o1.DeepFind("🌞") )
# Modernized to the canonical nested index-path format (engine-backed):
# top position 2, then 4.2 and 4.4, then 6.2.2. The old [[1,2],[2,2],[2,4],
# [3,2]] was the superseded [level, position] format.
#--> [ [ 2 ], [ 4, 2 ], [ 4, 4 ], [ 6, 2, 2 ] ]

o1.DeepReplace("🌞", :By = "♥")
? @@( o1.Content() )
#--> [
#	"1",
#	"♥",
#	"1",
#	[ "2", "♥", "2", "♥" ],
#	"1",
#	[ "2", [ "3", "♥" ] ]
# ]

o1.DeepRemove("♥")
? @@SP( o1.Content() )
#--> [
#	"1",
#	"1",
#	[ "2", "2" ],
#	"1",
#	[
#		"2",
#		[ "3" ]
#	]
# ]

StopProfiler()

pf()
# Executed in 0.03 second(s)
