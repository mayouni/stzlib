# Narrative
# --------
# #TODO/FUTURE
#
# Extracted from stzGlobalTest.ring, block #34.

load "../../stzBase.ring"


pr()

o1 = new stzString("SOanzNZA")
o1.ReplaceSection(3, 5, :With@ = 'Q(@char).Uppercased()')
? o1.Content()
#--> SOANZNZA

pf()
# Executed in 1.09
