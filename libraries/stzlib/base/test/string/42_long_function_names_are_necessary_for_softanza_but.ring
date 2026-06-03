# Narrative
# --------
# #narration: long function names are necessary for Softanza, but not for you!
#
# Extracted from stzStringTest.ring, block #42.

load "../../stzBase.ring"


pr()

# When you dig into the Softanza code, you may occasionally encounter functions
# with very long names, such as:

#                         7.9....4.6                3.5....4.2
o1 = new stzString("Hello <<<Ring>>>, the beautiful (((Ring)))!")
? @@( o1.FindSubStringBoundsUpToNCharsAsSections("Ring", 2) )
#--> [ [ 8, 9 ], [ 14, 15 ], [ 34, 35 ], [ 40, 41 ] ]

# This shouldn’t disappoint you. Let me explain why.

# Even though the function name clearly describes what it does (in this case,
# finding the substrings bounding "Ring" with up to 2 characters), it’s not
# meant to be used directly by you.

# These long functions are, in fact, used internally by other simpler functions
# that you will actually need in practice, while keeping the codebase more readable.

# In our case, the function you’d need is this one:

? o1.BoundsOfXT("Ring", 2, 2) # You will understand the XT() usage in a moment ;)
#--> [ [ "<<", ">>" ], [ "((", "))" ] ]

# This is what you should use when you don’t want all the bounding substrings returned
# (in this case all 3 chars), but only 2 chars from each bound.

# To return all the characters bounding the substring "Ring", you can use:

? o1.BoundsOf("Ring")
#--> [ [ "<<<", ">>" ], [ "(((", ")))" ] ]

# NOTE: Now you can see why we added the XT() extension to the BoundsOf() function name:
# it indicates an extended form of the main function, where you can specify the number
# of characters in the bound.

pf()
# Executed in 0.02 second(s) in Ring 1.21
