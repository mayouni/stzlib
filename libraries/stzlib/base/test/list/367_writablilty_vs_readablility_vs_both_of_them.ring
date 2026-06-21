# Narrative
# --------
# Two ways to say the same thing: Swap(1,3) and SwapItems(:AtPositions = 1, :And = 3).
#
# Softanza is built on a double promise: code should be WRITABLE (quick
# and frictionless to craft) and READABLE (its intent obvious to a future
# reader without external docs). The terse Swap(1, 3) form serves the
# writer in flow; the verbose SwapItems(:AtPositions = 1, :And = 3) form
# reads almost as plain English and serves the reader. Both compile to the
# same in-place swap of items at positions 1 and 3, so the same list flips
# from [C,B,A] to [A,B,C] and back -- you choose the style per moment.
#
# Extracted from stzlisttest.ring, block #367.

load "../../stzBase.ring"


pr()

# Softanza coding style is designed with a double promise in mind:
#  - Your code is WRITABLE: Easy to you while your are crafting it
#  - As well as READBALE: Easy easy to your reader to understand it.

# I'll explain this by code.

# Let's have a list, and then take two items inorder to swap them:

o1 = new stzList([ "C", "B", "A" ])

# You can quickly write:

o1.Swap(1, 3)
? o1.Content()
#--> ["A", "B", "C"]

# And you are done! Which means litterally: "swap items at positions 1 and 3".

# The point is that Softanza talks in near natural language tongue,
# and the sentence above can be written as-is in plain Ring code:

o1.SwapItems( :AtPositions = 1, :And = 3)

# It's: What You Think Is What You Get.

? o1.Content()
#--> [ "C", "B", "A" ]

# Let's recapitulate:

# WRITABILITY: you quickly write a function, always in a short form,
# without complications, because you need to focus on the thinking
# behind the solution not the underling syntax.

# READBILITY : Others, or yourself in the future, can read the function
# and understand the intent of its writer without referring
# to any external documentation).

# And in Softanza, you have them both...

pf()
# Executed in 0.02 second(s).
