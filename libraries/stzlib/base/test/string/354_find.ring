# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #354.
#ERR Error (R24) : Using uninitialized variable: i

load "../../stzBase.ring"

pr()

o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla {✤✤✤}")
? @@( o1.Find([ "♥♥♥", "✤✤✤" ]) ) # or FindMany()
#-->[ 6, 22, 35 ]

? @@( o1.TheseSubStringsZ([ "♥♥♥", "✤✤✤" ]) ) + NL
#--> [ [ "♥♥♥", [ 6, 22 ] ], [ "✤✤✤", [ 35 ] ] ]

? @@NL( o1.TheseSubStringsZZ([ "♥♥♥", "✤✤✤" ]) ) # or FindManyZZ()
#--> [
#	[ "♥♥♥", [ [ 6, 8 ], [ 22, 24 ] ] ],
#	[ "✤✤✤", [ [ 35, 37 ] ] ]
# ]

pf()
# Executed in 0.04 second(s) in Ring 1.21
