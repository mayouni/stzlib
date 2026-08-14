# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #2.

load "../../stzBase.ring"

pr()

# IsTrue() is RING TRUTHINESS, nothing more: StzIsTrue is `if p`. So a
# non-empty string is true here, exactly as it is in an ordinary Ring `if`.
? IsTrue("") #--> FALSE
? IsTrue("Hello") #--> TRUE

# The promise on that second line used to read FALSE, and the one above it
# read FLASE -- a typo that hid behind it. Nothing was strict about IsTrue;
# the file was describing a distinction it does not draw.

# IsTrueXT() is where Softanza's own notion of truth lives. It is not
# stricter or looser than IsTrue on a string -- it is TYPE-AWARE (lists,
# objects, the true/false/null wrappers) and CONFIGURABLE, which is what the
# rest of this file shows.
? IsTrueXT("Hello") #--> TRUE

? IsTrueXT("") #--> FALSE
# Because:
? EmptyStringIsConsideredFalse() #--> TRUE

# Change the default and try again:
SetEmptyStringIsConsideredFalse(0)
? IsTrueXT("") #--> TRUE

# ...and put it back, or every later file in this topic inherits the change:
# these are PROCESS globals.
SetEmptyStringIsConsideredFalse(1)
? IsTrueXT("") #--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.24
