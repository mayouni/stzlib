# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #634.
#ERR Error (R14) : Calling Method without definition: thesesubstringscsz

load "../../stzBase.ring"

pr()

o1 = new stzString("My name is Mansour. What's your name please?")

? @@( o1.FindManyCS( [ "name", "your", "please" ], TRUE ) ) + NL
#--> [ 4, 28, 33, 38 ]

? @@( o1.FindMany( [ "name", "your", "please" ] ) ) + NL
#--> [ 4, 28, 33, 38 ]

? @@( o1.TheseSubStringsCSZ( [ "name", "your", "please" ], TRUE ) ) + NL
#--> [ "name" = [ 4, 33 ], "your" = [ 28 ], "please" = [ 38 ] ]

o1 = new stzString("My name is Mansour. What's your name please?")
? @@(o1.TheseSubStringsZZ( [ "name", "nothing", "please" ] ))
#--> [ [ "name", [ [ 4, 7 ], [ 33, 36 ] ] ], [ "nothing", [ ] ], [ "please", [ [ 38, 43 ] ] ] ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18
# Executed in 0.11 second(s) in Ring 1.17
