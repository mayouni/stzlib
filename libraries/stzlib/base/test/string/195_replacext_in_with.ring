# Narrative
# --------
# #narration ReplaceXT( ..., In = ..., :With = ... )
#
# Extracted from stzStringTest.ring, block #195.

load "../../stzBase.ring"


pr()

# Suppose you have this string:

o1 = new stzString("*** Ring programmin* language ***")

# As you see, the substring "programmin*" contains a
# misspelled char at the end (the "*").

# Let's try to fix it.

# You make think that replacing the "*" by "g" solves it:

o1.Replace("*", :With = "g")
? o1.Content()
#--> ggg Ring programing language ggg

# but it doesn't! Because all the other "*"s are also replaced!

# To this particular situation, Softanza has an anwser:
# the ReplaceIn() function:

o1 = new stzString("*** Ring programmin* language ***")

? o1.ReplaceXT("*", :In = "programmin*", :With = "g")
? o1.Content()
#--> *** Ring programming language ***

pf()
# Executed in 0.05 second(s) in Ring 1.21
