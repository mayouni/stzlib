# Narrative
# --------
# /*
#
# Extracted from stzlistofstringstest.ring, block #1.

load "../../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "ring", "programming", "languag" ])
? o1.ConcatenatedUsing(" ")
#--> ring programming languag

o1 = new stzListOfStrings([ ])
? @@( o1.ConcatenatedUsing(" ") )
#--> ""

pf()
# Executed in 0.03 second(s)

#--------
/*
pr()

o1 = new stzListOfStrings([ "aa", "  ", "b", "     ", "ccc" ])
o1.RemoveBlankSpacesStrings()
? @@( o1.Content() )
#--> [ "aa", "b", "ccc" ]

pf()
# Executed in 0.03 second(s)
