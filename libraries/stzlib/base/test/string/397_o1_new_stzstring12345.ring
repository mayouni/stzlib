# Narrative
# --------
# o1 = new stzString("12345")
#
# Extracted from stzStringTest.ring, block #397.

load "../../stzBase.ring"

pr()

? o1.Section(2, 4)
#--> "234"

? o1.Section(2, -2)
#--> "234"

? o1.Section(:First, :Last)
#--> "12345"

? o1.Section(3, :@)
#--> "3"

? o1.Section(:@, 3)
#--> "3"

pf()
