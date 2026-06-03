# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #764.

load "../../stzBase.ring"


o1 = new stzString(" same   ")
o1 {
	TrimLeft()
	? @@( Content() )
	#--> "same   "

	TrimRight()
	? @@( Content() )
	#--> "same"
}

# Try also: TrimStart(), TrimEnd()
# RemoveLeadingSpaces(), and RemoveTrailingSpaces

pf()
# Executed in 0.02 second(s).
