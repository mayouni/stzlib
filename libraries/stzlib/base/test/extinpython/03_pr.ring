# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# range(n) : 0 <= x < n	--> n not included!

? range0(3)
#--> [ 0, 1, 2 ]

? @@( range0(-3) ) + NL
#--> []

# range(n1, n2): n1 <= x < n2

? range0([ 3, 10 ])
#--> [ 3, 4, 5, 6, 7, 8, 9 ]
	
? @@( range0([ 10, 3 ]) ) + NL
#--> []
	
? range0([ -3, 3 ])
#--> [-3, -2, -1, 0, 1, 2]
	
? @@( range0([ 3, -3 ]) )
#--> []
	
? range0Q([0, 3]) = range0(3)
#--> TRUE

# range(n1, n2, step): n1 <= x < n2 (increasing by step)

? range0([ 3, 10, 2 ])
#--> [ 3, 5, 7, 9 ]

? @@( range0([ 10, 3, 2 ]) ) + NL
#--> []

? range0([ 10, 3, -2 ])
#--> [ 10, 8, 6, 4 ]

? @@( range0([ 3, 10, -2 ]) )
#--> []

# range(start, stop, 1) is equivalent to range(start, stop)

? range0Q([ 3, 10, 1 ]) = range0([ 3, 10 ])
#--> TRUE

# range(0, stop, 1) is equivalent to range(0, stop) and range(stop)

? range0Q([ 0, 10, 1 ]) = range0Q([ 0, 10 ]) = range0(10)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
