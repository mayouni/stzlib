# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #686.
#ERR exit 1: 0

load "../../stzBase.ring"

pr()

# Quiet-eqality is particularily useful in french where "énoncé" and "ÉNONCÉ" are the same:

o1 = new stzString("énoncé")

? o1.IsEqualTo("enonce")
#--> FALSE

? o1.IsQuietEqualTo("enonce")
#--> TRUE

? o1.IsQuietEqualTo("ÉNONCÉ")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
