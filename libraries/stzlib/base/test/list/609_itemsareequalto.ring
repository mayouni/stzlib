# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #609.
#ERR Error (R14) : Calling Method without definition: itemsareequalto

load "../../stzBase.ring"

pr()

# All these return TRUE

o1 = new stzList([ "a", "a", "A", "A", "a", "A" ])

? o1.ItemsAreEqualTo("a")
#--> FALSE

? o1.ItemsAreEqualToCS("a", FALSE)
#--> TRUE

# You can also say:

? o1.ContainsOnly("a")
#--> FALSE

? o1.ContainsOnlyCS("A", FALSE)
#--> TRUE

pf()
# Executed in almost 0 second(s).
