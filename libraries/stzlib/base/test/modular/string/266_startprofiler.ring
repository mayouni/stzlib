# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #266.

load "../../../stzBase.ring"


o1 = new stzString("I love <<Ring>> and <<Softanza>>!")

# Finding the positions of substrings enclosed between << and >>

? @@( o1.FindAnyBoundedBy([ "<<",">>" ]) )
#--> [10, 23]

	# Returning the same result but as sections
	? @@( o1.FindAnyBoundedByAsSections([ "<<",">>"] ) ) # Or simply FindAnyBoundedByZZ()
	#--> [ [10, 13], [23, 30] ]

	# Getting the substrings themselves

	? @@( o1.AnyBoundedBy([ "<<",">>" ]) ) # Or SubStringsBoundedBy([ "<<", :And = ">>" ])
	#--> [ "Ring", "Softanza" ]

# Now, we need to do the same thing but we want to return the
# bounding chars << and >> in the result as well. To do so,
# we can use the IB/extended form of the same functions like this:

? @@( o1.FindAnyBoundedByIB([ "<<",">>" ]) )
#--> [8, 21]

	? @@( o1.FindAnyBoundedByAsSectionsIB([ "<<", ">>" ]) ) # Or Simply FindAnyBoundedByZZ()
	#--> [ [ 8, 15 ], [ 21, 32 ] ]

	? @@( o1.AnyBoundedByIB([ "<<",">>" ]) ) # Or SubStringsBoundedByIB()
	#--> [ <<Ring>>, <<Softanza>> ]

StopProfiler()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.12 second(s) in Ring 1.18
