# Narrative
# --------
# Quiet-Equality of two strings
#
# Extracted from stzStringTest.ring, block #685.

load "../../stzBase.ring"

$
pr()

o1 = new stzString("SOFTANZA IS AWSOME!")

#TODO // Check performance of IsQuietEqualTo() --> Root cause RemoveDiacritics()
#UPDATE Done, performance is now good (Ring 1.22)

? o1.IsQuietEqualTo("softanza is awsome!")
#--> TRUE

? o1.IsQuietEqualTo("Softansa is aowsome!")
#--> TRUE (we added an "o" to "awsome")

? o1.IsQuietEqualTo("Softansa iis aowsome!")
#--> FALSE (we add "i" to "is" and "o" to "awsome")

pf()
# Executed in 0.01 second(s) in Ring 1.22
