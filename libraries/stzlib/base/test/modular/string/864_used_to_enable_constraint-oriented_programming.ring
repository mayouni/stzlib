# Narrative
# --------
# Used to enable constraint-oriented programming
#
# Extracted from stzStringTest.ring, block #864.

load "../../../stzBase.ring"


pr()

o1 = new stzString("MustHave@32@CharsAnd@8@Spaces")
? o1.SubstringsBoundedBy("@") #--> ["32", "CharsAnd", "8" ]

o1 = new stzString("MustHave32CharsAnd8Spaces")
? @@( o1.SubstringsBoundedBy("@") ) #--> [ ]

pf()
# Executed in 0.01 second(s) in Ring 1.24
