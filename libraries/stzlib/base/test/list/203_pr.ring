# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #203.

load "../../stzBase.ring"


o1 = new stzList([ "1", "2", "3", "4", "5", "6", "7" ])

? o1.Section(3, 5)
#--> [ "3", "4", "5" ]

? o1.Section(5, 3)
#--> [ "3", "4", "5" ]

? o1.SectionXT(3, -3)
#--> [ "3", "4", "5" ]

? o1.SectionXT(-3, 3)
#--> [ "3", "4", "5" ]

? o1.Range(3, 3)
#--> [ "3", "4", "5" ]

? o1.RangeXT(3, 3)
#--> [ "1", "2", "3" ]

? o1.RangeXT(-5, 3)
#--> [ "1", "2", "3" ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
