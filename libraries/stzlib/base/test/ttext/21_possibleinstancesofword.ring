# Narrative
# --------
# //////////////////////////////////////
#
# Extracted from stzTtexttest.ring, block #21.

load "../../stzBase.ring"

pr()

# Finally, to bettter undersand what happens internally
# while Softanza analyses a text and try to recognize
# its words, these are the two simple steps performed:

# First, The instructions we saw in the above section, are used to
# generate a list of all possible instances of a given word
# in start, middle and and end of sentence. Like this:


? PossibleInstancesOfWord("Mahmoud")

# Then, those instances are searched one by one inside the text, so
# we can find all the possible forms the word takes in the text.

pf()
