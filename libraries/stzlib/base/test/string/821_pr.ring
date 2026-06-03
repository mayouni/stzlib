# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #821.

load "../../stzBase.ring"


o1 = new stzString("NoWomanNoCry")
? o1.SplitBeforeCharsWXT(:Where = 'Q(@char).IsUppercase()')
#--> [ "No", "Woman", "No", "Cry" ]

pf()
# Executed in 0.19 second(s) in Ring 1.22
