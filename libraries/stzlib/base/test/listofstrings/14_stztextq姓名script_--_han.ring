# Narrative
# --------
# ? StzTextQ("姓名").Script() #--> "han"
#
# Extracted from stzlistofstringstest.ring, block #14.
#ERR Error (E9) : Can't open file 14_stztextq??script_--_han.ring

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "name", "اسم", "姓名" ])
? o1.Scripts()
#--> [ "latin", "arabic", "han" ]

pf()
