# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #561.

load "../../stzBase.ring"


o1 = new stzString("abcde")

? o1.SplitToPartsOfNChars(2)
#--> [ "ab", "cd" ]

? o1.SplitToPartsOfNCharsXT(2)
#--> [ "ab", "cd", "e" ]

? o1.SplitAfterPositions([ 3, 4 ])
#--> [ "abc", "d", "e" ]

? o1.SplitAfterPositions([ 3, 5 ])
#--> [ "abc", "de" ]

? o1.SplitBeforePositions([ 3, 5 ])
#---> [ "ab", "cd", "e" ]

pf()
# Executed in 0.04 second(s) in Ring 1.21
