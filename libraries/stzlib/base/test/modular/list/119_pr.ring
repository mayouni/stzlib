# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #119.

load "../../../stzBase.ring"


o1 = new stzList([
	"me",
	"other",
	[ "other", "me", [ "me" ], "other" ],
	"other",
	"me"
])

o1.DeepReplace("me", :By = "you")
? @@( o1.Content() )
#--> [
#	"you",
#	"other",
#	[ "other", "you", [ "you" ], "other" ],
#	"other"
#    ]

pf()
