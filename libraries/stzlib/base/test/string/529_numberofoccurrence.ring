# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #529.

load "../../stzBase.ring"

pr()

o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")

? o1.NumberOfOccurrence(:OfSubString = "many")
#--> 5

? @@( o1.Positions(:of = "many") ) + NL	# or o1.FindSubString("many")
#--> [5, 12, 33, 40, 54]

? @@(o1.Sections(:Of = "many")) + NL # or o1.FindAsSections(:OfSubString = "many")
#--> [ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ], [ 40, 43 ], [ 54, 57 ] ]

	#NOTE that Sections() has an other syntax that returns, not the sections
	# as pairs of numbers as in the example above, the substrings corresponding
	# to the sections themselves:

	? o1.Sections([ [ 5, 8 ], [ 12, 15 ], [ 33, 36 ] ])
	#--> [ "many", "many", "many" ]

? o1.NumberOfOccurrenceXT(
	:OfSubString = "many",
	:BoundedBy = [ "<<", :and = ">>" ]
	# or :BoundedBySubStrings = ["<<", :and = ">>"]
)
#--> 3

pf()
# Executed in 0.11 second(s) in Ring 1.22
