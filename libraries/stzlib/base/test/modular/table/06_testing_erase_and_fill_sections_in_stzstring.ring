# Narrative
# --------
# TESTING ERASE AND FILL SECTIONS IN STZSTRINg
#
# Extracted from stztabletest.ring, block #6.

load "../../../stzBase.ring"


pr()

o1 = new stzString("[**Word1***Word2**Word3***]")

aSections = [ [2,3], [9, 11], [17, 18], [24, 26] ]
? @@(o1.Sections(aSections))
#--> [ "**", "***", "**", "***" ]

o1.FillSections(aSections, :With = "^")

? o1.Content()
#--> '[^^Word1^^^Word2^^Word3^^^]'

o1.EraseSections(aSections)
? o1.Content()
#--> '[  Word1   Word2  Word3   ]'

pf()
# Executed in 0.08 second(s) in Ring 1.22
