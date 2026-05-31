# Narrative
# --------
# Test 4: Word Boundaries
#
# Extracted from stzRegexTest.ring, block #36.

load "../../../stzBase.ring"


pr()

o1 = new stzRegex("pre\w+")

# Word boundary matching with MatchWordsIn()

? o1.MatchWordsIn("prefix preprocess present compress")  # matches pre* words
#--> TRUE

# Should fail on compress

? o1.MatchWordsIn("compress")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22
