# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #186.
#ERR exit 1: Line 79 Bad parameters value, error in length!

load "../../stzBase.ring"


pr()

# Let's start with this string of text:

o1 = new stzString("<<♥♥♥>>--<<stars>>--<<♥♥♥>>")

# If you want to extract all substrings bounded by << and >>,
# you can do so easily:

? o1.BoundedBy([ "<<", ">>" ])
#--> ["♥♥♥", "stars", "♥♥♥"]

# There are 3 substrings, and 2 of them are identical! No worries,
# you can retrieve only the unique substrings by appending the
# letter "U" (for Unique) to the function name:

? o1.BoundedByU([ "<<", ">>" ])
#--> ["♥♥♥", "stars"]

# Sometimes, the term "BETWEEN" can be interpreted differently,
# and you might want  to include the bounds along with the substrings. 

# This can be achieved by adding the "IB" prefix to the function
# name ("IB" for "Include Bounds"):

? o1.BoundedByIB([ "<<", ">>" ])
#--> [ "<<♥♥♥>>", "<<stars>>", "<<♥♥♥>>" ]

# Wonderful! But notice that "<<♥♥♥>>" appears twice...
# No problem, you know the solution: just append the "U" prefix:

? o1.BoundedByIBU([ "<<", ">>" ])
#--> [ "<<♥♥♥>>", "<<stars>>" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.15 second(s) in Ring 1.18


pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.15 second(s) in Ring 1.18
