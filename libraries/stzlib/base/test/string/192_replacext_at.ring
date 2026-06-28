# Narrative
# --------
# ReplaceXT(sub, :At = n, :With = new) replaces the occurrence of sub that STARTS
# at character POSITION n (not the n-th occurrence). Here the heart at position 2
# becomes "~", leaving the heart at position 4 untouched.
#
# Extracted from stzStringTest.ring, block #192.

load "../../stzBase.ring"

pr()

o1 = new stzString("~♥/♥\~~")
o1.ReplaceXT("♥", :At = 2, :With = "~")
? o1.Content()
#--> ~~/♥\~~

pf()
