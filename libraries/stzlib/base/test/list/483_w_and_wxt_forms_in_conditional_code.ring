# Narrative
# --------
#
# Extracted from stzlisttest.ring, block #483.

load "../../stzBase.ring"

pr()

# Finding positions where next number is double of previous number
o1 = new stzList([ 2, 8, 2, 11, 2, 11, 1, 4, 2, 1, 3, 2, 10, 8, 3, 6, 8 ])

? @@( o1.FindW( '{ Q( @NextNumber ).IsDoubleOf( @PreviousNumber ) }' ) ) #--> [ 8, 11 ]
#--> [ 8, 11 ]


pf()
# Executed in 0.01 second(s) in Ring 1.27
# Executed in 0.28 second(s) before
