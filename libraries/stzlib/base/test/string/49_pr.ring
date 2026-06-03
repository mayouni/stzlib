# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #49.

load "../../stzBase.ring"


o1 = new stzString("Ring Programming Language")

? o1.Section(6, o1.RandomPositionAfter(6) )
#--> Programming Lang

? o1.Section(6, o1.FindNth(3, "g") )
#--> Programming

? o1.Section( :From = "L", :To = "e")
#--> Language

#--

? o1.Range(6, 11)
#--> Programming

? o1.SectionXT(6, :UpToNCHars = 11)
#--> Programming

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.08 second(s) in Ring 1.19
