# Narrative
# --------
# stzExtCode #todo quick-narration
#
# Extracted from stzmisctest.ring, block #4.

load "../../../stzBase.ring"


pr()

# Softanza simplifies the use of substr() which has
# many forms in Ring and outside Ring (if you ar generating
# code from LLMs that are ususally influenced by pyhton and
# C syntax of substr()). You only need
# to add @ before substr() and let Softanza manage
# all the possible cases:

# Case 1 : Replacing a substring by an other

? @substr("one five three", "five", "two")
#--> one two three

# Case 2 : Finding the first occurrence of a substring
? @substr("one two three", "two", []) # [] can also be 0
#--> 5

# Case 3 : Getting a section from the string
? @substr("one two three", 6, 8)
#--> two

# Case 4 : Finding the first occurrence of a substring
# starting at a give position

? @substr("one two three two", "two", 10)
#--> 15

pf()
# Executed in 0.01 second(s) in Ring 1.22
