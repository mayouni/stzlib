# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #106.

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
#--> [ 1, 2 ], [ 2, 2 ], [ 2, 4 ], [ 3, 2 ] ]
# 🌞 exists in level 1 at position 2, in level 2 at positions 2 and 4, and in level 3 at position 2.

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
