# Narrative
# --------
# ? StzTextQ("姓名").Script() #--> "han"
#
# Extracted from stzlistofstringstest.ring, block #14.

load "../../../stzBase.ring"


o1 = new stzListOfStrings([ "name", "اسم", "姓名" ])
? o1.Scripts()
#--> [ "latin", "arabic", "han" ]
