load "../max/stzmax.ring"

pr()

o1 = new stzListOfUnicodes( Arabic7araketUnicodes() )

? @@NL( o1.UnicodesAndChars() )
#--> [
#	[ 1615, "ُ" ],
#	[ 1614, "َ" ],
#	[ 1616, "ِ" ],
#	[ 1618, "ْ" ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.21
