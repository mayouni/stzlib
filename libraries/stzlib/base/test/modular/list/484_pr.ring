# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #484.

load "../../../stzBase.ring"


o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

# The function above you can also write like this:
? o1.FindWXT( :Where = '{ Q( @NextItem ).IsDoubleOf( @PreviousItem ) }' )
#--> [ 8, 11 ]

# or like this:
? o1.FindWhere( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' )
#--> [ 8, 11 ]

pf()
# Executed in 0.28 second(s).
