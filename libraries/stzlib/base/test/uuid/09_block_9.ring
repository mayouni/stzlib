# Narrative
# --------
# #ring
#
# Extracted from stzuuidtest.ring, block #9.

load "../../stzBase.ring"


pr()

myList1 = [new Company {position=3 name="Mahmoud" symbol="MHD"},
           new Company {position=2 name="Bert" symbol="BRT"},
           new Company {position=1 name="Ring" symbol="RNG"}
          ]

see find(mylist1,"Bert", 1, "name") #--> 2

pf()
# Executed in almost 0 second(s) in Ring 1.24

class company position name symbol
