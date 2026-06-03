# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #345.

load "../../stzBase.ring"


? Q([ "واحد", "اثنان", "ثلاثة" ]).Are(:Strings)
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).Are([ :Arabic, :Strings ])
#--> TRUE

? Q([ "واحد", "اثنان", "ثلاثة" ]).Are([ :ArabicScript, :RightToLeft, :Texts ])
#--> TRUE

pf()
# Executed in 0.26 second(s).
