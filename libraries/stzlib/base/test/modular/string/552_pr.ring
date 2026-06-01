# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #552.

load "../../../stzBase.ring"


# For each one of the 3 function calls we made so far (see
# example above), you can get the result as sections and not
# as positions. To do so, just use the same functions while
# adding the keyword Sections like this:

o1 = new stzString("txt <<ring>> txt <<php>>")

? @@( o1.FindBoundedByZZ([ "<<", ">>" ]) ) + NL
#--> [ [ 7, 10 ], [ 20, 22 ] ]

o1 = new stzString("*2*45*78*0*")
? @@( o1.FindBoundedByZZ("*") ) + NL
#--> [ [ 2, 2 ], [ 4, 5 ], [ 7, 8 ], [ 10, 10 ] ]

? @@( o1.FindAnyBoundedByIBZZ("*") )
#--> [ [ 1, 3 ], [ 3, 6 ], [ 6, 9 ], [ 9, 11 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.13 second(s) in Ring 1.18
