# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #335.

load "../../stzBase.ring"


o1 = new stzList(["1","2","3","4","5"])

? o1.Section(2, 4)
#--> [ "2","3","4" ]

? o1.SectionXT(2, -2)
#--> [ "2","3","4" ]

? o1.Section(:First, :Last)
#--> ["1","2","3","4","5"]

? o1.Section(3, :@)
#--> [ "3" ]

? o1.Section(:@, 3)
#--> [ "3" ]

pf()
# Executed in 0.01 second(s).
