# Narrative
# --------
# #  Testing Complete stzRegex Implementation  #
#
# Extracted from stzRegexTest.ring, block #33.

load "../../stzBase.ring"

#--------------------------------------------#

# Test 1: Basic Pattern Matching with Match

pr()

o1 = new stzRegex("quick.*fox")

# Pattern should match

? o1.Match("The quick brown fox")  # Or MatchString()
#--> TRUE

# Pattern should not match

? o1.Match("slow blue fox")  # false
#--> FALSE

prf()
# Executed in 0.01 second(s) in Ring 1.22
