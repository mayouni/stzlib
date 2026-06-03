# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #360.

load "../../stzBase.ring"


o1 = new stzList([
	"me",
	"other",
	[ "other", "me", [ "me" ], "other" ],
	"other",
	"me"
])

o1.DeepReplace("me", :By = "you")
? @@NL( o1.Content() )

#--> [
#	"you",
#	"other",
#	[ "other", "you", [ "you" ], "other" ],
#	"other"
#    ]

pf()
# Executed in 0.01 second(s).
