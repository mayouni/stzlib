# Narrative
# --------
# #narration
#
# Extracted from stzchartest.ring, block #110.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

_cRightToLeftOverride = "‮"
# Do you think this is an empty Char?
# Let's see...

o1 = new stzChar(_cRightToLeftOverride)
? o1.IsEmpty() # It's not! (returns FALSE)

# Nor it is a whitespace...
? o1.IsWhitespace() #--> FALSE

# Let's see why?
? o1.UnicodeCategory() # it belongs to other_format unicode category
? o1.Unicode() # it has a unicode (8238)
? o1.IsPrintable() # it's not printable
? o1.IsRightToLeftOverride() # it's the RLO unicode Char!

# What if we see its name!
? o1.Name() #--> RIGHT-TO-LEFT OVERRIDE

pf()
# Executed in 0.01 second(s) in Ring 1.27
# Executed in 0.03 second(s) in Ring 1.23
