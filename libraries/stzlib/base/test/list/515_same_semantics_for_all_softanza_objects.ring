# Narrative
# --------
# #narration Same semantics for all softanza objects
#
# Extracted from stzlisttest.ring, block #515.

load "../../stzBase.ring"


pr()

# Softanza works consistently on lists and strings: What works
# for a string, would generally work for a list, when it makes
# sense, using the same semantics.

# For example, in strings, we can check if the string is bounded
# by two given substrings, or even by many of them. So, we say:

oStr = new stzString("|<--Scope of Life-->|")
? oStr.IsBoundedBy([ "|<--", "-->|" ])
#--> TRUE

# And then we can delete these bounds:
? oStr.TheseBoundsRemoved( "|<--", "-->|" )
#--> "Scope of Life"

# The same semantics apply to lists, like this:

oList = new stzList([ "|<--", "Scope", "of", "Life", "-->|" ])
? oList.IsBoundedBy([ "|<--", "-->|" ])
#--> TRUE

# And we can remove all these bounds, exactly like we did for strings:
? oList.TheseBoundsRemoved( "|<--", "-->|" )
#--> [ "Scope", "of", "Life" ]

pf()
# Executed in 0.05 second(s).
