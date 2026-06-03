# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #241.

load "../../stzBase.ring"

   
o1 = new stzString("123456789")

# FIRST HALF

	? o1.FirstHalf()
	#--> 1234

	? o1.FirstHalfXT()
	#--> 12345
	
	? @@( o1.FirstHalfZ() )
	#--> [ "1234", 1 ]

	? @@( o1.FirstHalfZZ() )
	#--> [ "1234", [ 1, 4 ] ]
	
	? @@( o1.FirstHalfXTZ() )
	#--> [ "12345", 1 ]

	? @@( o1.FirstHalfXTZZ() ) + NL
	#--> [ "12345", [ 1, 5 ] ]

# SECOND HALF

	? o1.SecondHalf()
	#--> 56789

	? o1.SecondHalfXT()
	#--> 6789
	
	? @@( o1.SecondHalfZ() )
	#--> [ "56789", 5 ]

	? @@( o1.SecondHalfZZ() )
	#--> [ "56789", [ 5, 9 ] ]
	
	? @@( o1.SecondHalfXTZ() )
	#--> [ "6789", 6 ]

	? @@( o1.SecondHalfXTZZ() ) + NL
	#--> [ "6789",  [ 6, 9 ] ]

#-- THE TWO HALVES

	? @@( o1.Halves() )
	#--> [ "1234", "56789" ]

	? @@( o1.HalvesXT() )
	#--> [ "12345", "6789" ]

	? @@( o1.HalvesZ() )
	#--> [ [ "1234", 1 ], [ "56789", 5 ] ]

	? @@( o1.HalvesXTZ() )
	#--> [ [ "12345", 1 ], [ "6789", 6 ] ]

	? @@( o1.HalvesZZ() )
	#--> [ [ "1234", [ 1, 4 ] ], [ "56789", [ 5, 9 ] ] ]

	? @@( o1.HalvesXTZZ() )
	#--> [ [ "12345", [ 1, 5 ] ], [ "6789", [ 6, 9 ] ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.21
