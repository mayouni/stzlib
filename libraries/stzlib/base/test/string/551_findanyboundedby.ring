# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #551.
#ERR Error (R14) : Calling Method without definition: findanyboundedbyib

load "../../stzBase.ring"

pr()

o1 = new stzString("*2*45*78*0*")

? @@( o1.FindAnyBoundedBy([ "*","*" ]) ) + NL # Or o1.FindAnyBoundedBy("*") 
#--> [ 2, 4, 7, 10 ]

? @@( o1.FindAnyBoundedByIB("*") ) + NL # Or o1.FindAnyBetweenIB("*", "*")
#--> [ 1, 3, 6, 9 ]

? @@( o1.AnyBoundedBy("*") ) + NL
#--> [ "2", "45", "78", "0" ]

? @@NL( o1.AnyBoundedByZZ("*") )
# [
#	[ "2", 	[ 2, 2 ] ],
#	[ "45", [ 4, 5 ] ],
#	[ "78", [ 7, 8 ] ],
#	[ "0", 	[ 10, 10 ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.31 second(s) in Ring 1.18
