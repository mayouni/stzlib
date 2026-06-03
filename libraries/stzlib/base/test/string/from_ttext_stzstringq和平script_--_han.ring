# Narrative
# --------
# ? StzStringQ("和平").Script() #--> :Han
#
# Extracted from stzTtexttest.ring, block #6.
#ERR Error (E9) : Can't open file from_ttext_stzstringq??script_--_han.ring

load "../../stzBase.ring"

pr()

? StzStringQ("和平 210").Script() #--> :Han
? StzStringQ("和平 210").Scripts() #--> [ :Han, :Common ]

? StzStringQ("和平 is 'peace' in chineese!").Script() #--> :Hybrid
? StzStringQ("和平 is 'peace' in chineese!").Scripts() #--> [ :Han, :Common, :Latin ]
#--> Returns :Hybrid

pf()
