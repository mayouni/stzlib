# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #42.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? StzCharQ("_").IsWordNonLetterChar() #--> TRUE
? WordNonLetterChars()
#--> [ "_", "-", "*", "/", "\", "+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
