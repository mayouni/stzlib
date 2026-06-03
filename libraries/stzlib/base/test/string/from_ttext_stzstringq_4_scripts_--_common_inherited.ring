# Narrative
# --------
# ? StzStringQ(" 4  ُ  ").Scripts() #--> [ :Common, :Inherited ]
#
# Extracted from stzTtexttest.ring, block #10.
#ERR exit 1: Line 79 Bad parameters value, error in length!

load "../../stzBase.ring"

pr()

? StzStringQ(" 4  ُ  ").Script()	 #--> :Inherited

pf()
