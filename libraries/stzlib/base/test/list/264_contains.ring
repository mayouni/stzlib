# Narrative
# --------
# Probes a stzList for an item that is not present.
#
# Contains() answers the membership question and FindFirst() answers
# the position question. For the absent substring-looking item "n"
# (note: the list holds whole strings like "ab", "abnA", not chars),
# Contains() returns the boolean miss and FindFirst() returns the
# zero position. Ring prints both as 0 -- FALSE and the not-found
# position 0 are the same scalar at the console -- so the recorded
# FALSE labels intent while the run prints 0.
#
# Extracted from stzlisttest.ring, block #264.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "ab", "abnA", "abAb" ])

? o1.Contains("n")
#--> FALSE

? o1.FindFirst("n")
#--> 0

pf()
# Executed in 0.02 second(s)
