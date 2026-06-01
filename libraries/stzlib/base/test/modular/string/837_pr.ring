# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #837.

load "../../../stzBase.ring"


# You can use InsertSubStringsXT() with just the configurations you want:

o1 = new stzString("All our software versions must be updated!")
o1.InsertSubStringsXT(
	o1.PositionAfter("versions"),
	[ " V1", "V2", "V3" ],
	[ :MainSeparator = "+" ]
)
? o1.Content()
#--> All our software versions V1+V2+V3 must be updated!

pf()
# Executed in 0.02 second(s).
