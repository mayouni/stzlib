# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #520.
#ERR Error (R14) : Calling Method without definition: findsubstring

load "../../stzBase.ring"

pr()

o1 = new stzString("*AB*")

? @@( o1.Find("*") )
#--> [1, 4]

# Or you can say:
? @@( o1.Find( :SubString = "*" ) )
#--> [1, 4]

# Or also:
? @@( o1.FindSubString( "*" ) )
#--> [1, 4]

# And many other alternatives that you can discover in the fucntion code

pf()
# Executed in 0.02 second(s) in Ring 1.22
