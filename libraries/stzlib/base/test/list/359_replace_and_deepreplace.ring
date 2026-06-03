# Narrative
# --------
# Replace and DeepReplace
#
# Extracted from stzlisttest.ring, block #359.

load "../../stzBase.ring"


pr()

o1 = new stzList([
	"me",
	"other",
	[ "other", "me", [ "me" ], "other" ],
	"other",
	"me"
])

o1.Replace("me", :By = "you")
? @@NL( o1.Content() ) + NL

#--> [
#	"you",
#	"other",
#	[ "other", "me", [ "me" ], "other" ],
#	"other",
#	"you"
#    ]

pf()
# Executed in almost 0 second(s).
