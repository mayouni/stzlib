# Narrative
# --------
# The two forms of conditional code: ...W() (performant) vs ...WXT() (expressive).
#
# Both drive Softanza's list queries. The W form is faster but limited to the
# basic keywords (@item, @string, @i, and This[@i-1] / This[@i+1] index math);
# the WXT form trades speed for richer relational keywords like @NextNumber and
# @PreviousNumber. Here both locate positions where the next number is double
# the previous one -- FindWXT('{ Q(@NextNumber).IsDoubleOf(@PreviousNumber) }')
# and the equivalent index-arithmetic FindW('{ Q(This[@i+1]).IsDoubleOf(This[@i-1]) }')
# both return [ 8, 11 ]. (The ElapsedTime() line is wall-clock timing, so its
# printed value varies run to run.)
#
# Extracted from stzlisttest.ring, block #483.

load "../../stzBase.ring"

pr()

# In conditional code, there are always to forms:
#	- the ...W(pcCondition) form, which is more performant, but less expressive
#	- the ...WXT(pcCondition) form, which is less performant, but more expressive

# In the first form, you can only use the @item, @string, ... and the @i keywords.
# While in the second, you can use keywords sutch as @NextItem, @PreviousItem, and others.

# You can always express these additional keywords, while option for the more performant
# form, by transalating them to This[@i-1] for @PreviousItem, for example, and to
# This[@i+1] for @NextItem, etc.

StartProfiler()

# Finding positions where next number is double of previous number
o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

? @@( o1.FindWXT( '{ Q( @NextNumber ).IsDoubleOf( @PreviousNumber ) }' ) ) #--> [ 8, 11 ]
#--> [ 8, 11 ]

? ElapsedTime() + NL
#--> 0.19 second(s)

? @@( o1.FindW( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' ) )  #--> [ 8, 11 ]
#--> [ 8, 11 ]

StopProfiler()

pf()
# Executed in 0.28 second(s).
