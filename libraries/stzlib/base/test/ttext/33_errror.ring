# Narrative
# --------
# ///// ERRROR /////
#
# Extracted from stzTtexttest.ring, block #33.
#ERR Error (R3) : Calling Function without definition: stztextgq

load "../../stzBase.ring"

pr()

# When you try to remove the diacritics of the german word "München"
? StzTextgQ("München").DiacriticsRemoved() #--> "Munchen"

# Softanza tries its best and returns "Munchen".

# But this is not correct, since an e should be added after the u that
# replaced ü. To make it right, you need to inform Softanza about the
# locale to use as a context for the undiacritization operation.

# Hence, you should say:
? StzTextQ("München").DiacriticsRemovedInLocale([ :Language = :German ]) # "Muenchen"

# and you're done with the correct answer!

pf()
