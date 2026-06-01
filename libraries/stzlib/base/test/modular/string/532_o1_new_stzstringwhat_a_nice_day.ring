# Narrative
# --------
# o1 = new stzString("what a <<nice>>> day!")
#
# Extracted from stzStringTest.ring, block #532.

load "../../../stzBase.ring"


# All these return an error message:

? o1.Section(50, 0)	#-->NULL
? o1.Section(0, 0)	#-->NULL
? o1.Section(-20, 10)	#-->NULL

#--> ERROR MESSAGE:
#--> Indexes out of range! n1 and n2 must be inside the string.
