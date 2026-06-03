# Narrative
# --------
# #  Understanding Regex Options  #
#
# Extracted from stzRegexTest.ring, block #28.

load "../../stzBase.ring"

#-------------------------------#

# Test 1: Basic dot behavior

pr()

txt = "hello
world"

o = new stzRegex("hello.world")

# Without DotMatchesAll

? o.MatchXT(txt, 1, :MatchEntireContent, []) # Returns false - dot doesn't match newline
#--> FALSE

# With DotMatchesAll
? o.MatchXT(txt, 1, :MatchEntireContent, [ :DotMatchesAll ]) # Returns true - dot matches newline
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
