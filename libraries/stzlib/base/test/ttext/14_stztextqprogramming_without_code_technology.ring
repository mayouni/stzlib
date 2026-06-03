# Narrative
# --------
# StzTextQ("Programming Without Code Technology") {
#
# Extracted from stzTtexttest.ring, block #14.

load "../../stzBase.ring"


	? Initials()
	#--> [ "P", "W", "C", "T" ]

	? InitialsAsString()
	#--> PWCT

	# Or you can return any type you need using the QRT() construct:
	? InitialsQRT(:stzString).Content()
}
