# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #361.
#ERR Error (R14) : Calling Method without definition: insert

load "../../stzBase.ring"

pr()

# to get the background of this sample, read this:
# https://groups.google.com/g/ring-lang/c/_33L7miE3QM

# First way: Substring first

o1 = new stzString("ACD")
o1.Insert("B", :BeforePosition = 2)
? o1.Content()
#--> "ABCD"

# Second way: Position first

o1 = new stzString("ACD")
o1.InsertBefore( :Position = 2, :SubString = "B")
? o1.Content()
#--> "ABCD"

# Short forms:

o1.Insert("B", 2)
o1.InsertBefore(2, "B")
? o1.Content()
#--> ABBBCD

#TODO // add ( :Position = ... and :SubString = ... ) everywhere!
#UPDATE: done!

pf()
# Executed in 0.02 second(s).
