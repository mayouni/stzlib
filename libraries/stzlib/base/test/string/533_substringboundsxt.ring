# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #533.
#ERR Error (R14) : Calling Method without definition: substringboundsxt

load "../../stzBase.ring"

pr()

o1 = new stzString("How many <<many>> are there in (many <<many>>): so <<many>>!")

? @@( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = 1 ) ) + NL
#--> [ "<", ">", "(", "<", ">", "<", ">" ]

# Same as:
? @@( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = [1, 1] ) ) + NL
#--> [ "<", ">", "(", "<", ">", "<", ">" ]

? @@( o1.SubStringBoundsXT( :Of = "many", :UpToNChars = [ 1, 2 ] ) ) + NL
#--> [ "<", ">>", "(", "<", ">>", "<", ">>" ]

? @@( o1.SubStringBoundsXT(:Of = "many", :UpToNChars = [ 2, 2 ] ) ) + NL
#--> [ "<<", ">>", "(", "<<", ">>", "<<", ">>" ]

pf()
# Executed in 0.09 second(s) in Ring 1.22
