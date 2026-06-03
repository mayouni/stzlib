# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #53.

load "../../stzBase.ring"

o1 = new stzList([ "ring", "php", "ruby", "ring", "python", "ring" ])
o1.ReplaceByMany("ring", [ "♥", "♥♥", "♥♥♥" ])
	
? o1.Content()
#--> [ "♥", "php", "ruby", "♥♥", "python", "♥♥♥" ]

pf()
# Executed in 0.03 second(s)
