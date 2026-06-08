# Narrative
# --------
# #narration
#
# Extracted from stzStringTest.ring, block #45.

load "../../stzBase.ring"


pr()

# In Softanza, if you have a string bounded by some chars,
# you can remove them to keep only the string:

o1 = new stzString("<<Go!>>")
? o1.TheseBoundsRemoved("<<", ">>")
#--> "Go!"

# In case you don't know the bounds, Softanza knows them,
# and can remove them for you:

o1 = new stzString("<<Go!>>")
? o1.Bounds()
#--> [ "<<", ">>" ]

? o1.BoundsRemoved()
#--> "Go!"

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.24 second(s) in Ring 1.18
