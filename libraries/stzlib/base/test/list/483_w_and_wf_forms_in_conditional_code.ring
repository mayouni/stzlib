# Narrative
# --------
# The two clean conditional-code forms in Softanza: ...W() and ...WF().
#
# ...W() takes a condition as a string-DSL evaluated by the engine -- it is
# both performant AND expressive: it understands @item, @i, the raw index
# math This[@i-1] / This[@i+1], AND the expressive cursor keywords
# @NextItem / @PreviousItem / @NextNumber / @PreviousNumber (transpiled to
# the index form, with neighbour access auto-bounded).
#
# ...WF() takes a real Ring anonymous function instead of a string -- use it
# when the predicate needs arbitrary Ring logic.
#
# (The older ...WXT() "extended" form is retired: W now does everything it
# did.) Here both spellings of the same scan -- positions where the next
# number is the double of the previous one -- return [ 8, 11 ].
#
# Extracted from stzlisttest.ring, block #483.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

# Expressive cursor keywords:
? @@( o1.FindW( '{ Q( @NextNumber ).IsDoubleOf( @PreviousNumber ) }' ) )
#--> [ 8, 11 ]

# The same scan written with raw index math:
? @@( o1.FindW( '{ Q( This[@i+1] ).IsDoubleOf( This[@i-1] ) }' ) )
#--> [ 8, 11 ]

pf()
# Executed in 0.28 second(s).
