# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #5.

load "../../../stzBase.ring"


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
# Executed in almost 0 second(s) in Ring 1.22
