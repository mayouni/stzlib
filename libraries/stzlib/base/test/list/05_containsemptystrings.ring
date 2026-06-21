# Narrative
# --------
# The empty-string toolkit: detect, count, locate, replace, and remove the
# "" holes in a list.
#
# ContainsEmptyStrings / CountEmptyStrings / FindEmptyStrings answer the
# questions; ReplaceEmptyStrings(:With = ...) fills the holes in place, and
# RemoveEmptyStrings deletes them outright. A common cleanup step for ragged
# data with blank cells.
#
# Extracted from stzlisttest.ring, block #5.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", '', "B", '', '', "C" ])

? o1.ContainsEmptyStrings()
#--> TRUE

? o1.CountEmptyStrings() + NL
#--> 3

? o1.FindEmptyStrings()
#--> [ 2, 4, 5 ]

o1.ReplaceEmptyStrings(:With = "~")
? o1.Content()
#--> [ "A", '~', "B", '~', '~', "C" ]

#--

o1 = new stzList([ "A", '', "B", '', '', "C" ])
o1.RemoveEmptyStrings()
? o1.Content()
#--> [ "A", "B", "C" ]

pf()
# Executed in almost 0 second(s)
