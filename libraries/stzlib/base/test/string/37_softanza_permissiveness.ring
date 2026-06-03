# Narrative
# --------
# #narration: Softanza permissiveness
#
# Extracted from stzStringTest.ring, block #37.
#ERR Error (R14) : Calling Method without definition: removefirstcharcs

load "../../stzBase.ring"


pr()

# Suppose you have a string like this:

o1 = new stzString("rRing")

# And you want to remove the first character:

o1.RemoveFirstChar()
? o1.Content()
#--> Ring

# Now, what if you consider applying case sensitivity here?
# Meaning, you want the removal operation to be case sensitive...

# Actually, this doesn't make much sense, since the first character
# is the first character, regardless of its case!

# However, Softanza doesn't mind and allows you to apply it,
# but completely ignores the case sensitivity parameter:

o1 = new stzString("rRing")
o1.RemoveFirstCharCS(TRUE)
? o1.Content()
#--> Ring

# NOTE: This feature is available only for this function
# to demonstrate the principle of PERMISSIVENESS.
#~> It will be generalized in the future.

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.19
