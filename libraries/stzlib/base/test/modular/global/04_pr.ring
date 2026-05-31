# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #4.

load "../../../stzBase.ring"


? BothAreEqual(0, "")
#--> FALSE

? BothAreEqual(1, "1")
#--> FALSE

? BothAreEqual([], "")
#--> FALSE

? BothAreEqual(1:3, [1, 2, 3])
#--> TRUE

? BothAreEqual("ring", "ring")
#--> TRUE

 ? BothAreEqual("RING", "ring")
#--> FALSE

? BothAreEqualCS("RING", "ring", FALSE)
#--> TRUE

? BothAreEqual("A":"C", "a":"c")
#--> FALSE

? BothAreEqualCS("A":"C", "a":"c", FALSE)
#--> TRUE

pf()
#--> Executed in 0.01 second(s) in Ring 1.21
#--> Executed in 0.04 second(s) in Ring 1.20
