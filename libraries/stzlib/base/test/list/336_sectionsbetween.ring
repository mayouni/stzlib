# Narrative
# --------
# Demonstrates stzList.SectionsBetween(start, end): collecting every
# contiguous run that begins at a `start` item and closes at the next
# `end` item.
#
# Given [ "T","A","Y","O","U","B","T","A" ], asking for the sections
# between "T" and "A" yields three runs: the leading ["T","A"] pair,
# the long span from the first "T" all the way to the final "A"
# (["T","A","Y","O","U","B","T","A"]), and the trailing ["T","A"]
# pair. Each start is paired with a closing end, so overlapping spans
# (a wide outer match plus the inner pairs) are all reported rather
# than collapsing to a single greedy match. @@NL() pretty-prints the
# nested result one section per line.
#
# Extracted from stzlisttest.ring, block #336.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "T", "A", "Y", "O", "U", "B", "T", "A" ])
? @@NL( o1.SectionsBetween( "T", "A" ) )
#--> [
#	["T", "A"],
#	[ "T", "A", "Y", "O", "U", "B", "T", "A" ],
#	["T", "A"]
# ]

pf()
# Executed in almost 0 second(s).
