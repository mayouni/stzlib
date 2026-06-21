# Narrative
# --------
# Classify() groups a list into named classes, mapping each distinct
# value to the positions where it occurs.
#
# Given a list of language tags, Classify() returns a list of
# [ value, positions ] pairs: each unique value paired with the
# 1-based indices at which it appears (e.g. "arabic" => [ 1, 2, 8 ]).
# Classes() projects just the distinct values in first-seen order,
# and NumberOfClasses() counts them. The @@SP() rendering of the
# Classify() result is the structured pair-list shown below; note
# that string keys come back lowercased ("arabic", not :Arabic).
#
# Extracted from stzlisttest.ring, block #386.

load "../../stzBase.ring"

pr()

aList = [
	:Arabic,
	:Arabic,
	:French,
	:English,
	:Spanish,
	:Spanish,
	:English,
	:Arabic
]

StzListQ(aList) {

 	? @@SP( Classify() ) + NL
	#--> [ [ "arabic", [ 1, 2, 8 ] ], [ "french", [ 3 ] ], [ "english", [ 4, 7 ] ], [ "spanish", [ 5, 6 ] ] ]

	? Classes()
	#--> [ "arabic", "french", "english", "spanish" ]

	? NumberOfClasses()
	#--> 4
}

pf()
# Executed in 0.02 second(s).
