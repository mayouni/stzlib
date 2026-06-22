# Narrative
# --------
# Demonstrates Softanza's uniform semantics: an operation defined on
# strings carries over to lists with the same name and meaning.
#
# A string can be tested for being framed by two delimiters with
# IsBoundedBy, and those frames stripped with TheseBoundsRemoved.
# The identical idiom applies to a list: IsBoundedBy checks whether
# the first and last items are the given bounds, and TheseBoundsRemoved
# returns the inner items with those bounds dropped. One vocabulary,
# two object kinds -- so what you learn on strings transfers to lists
# whenever it makes sense.
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
