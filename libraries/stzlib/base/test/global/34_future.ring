# Narrative
# --------
# #TODO/FUTURE
#
# Extracted from stzGlobalTest.ring, block #34.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzString("SOanzNZA")
o1.ReplaceSection(3, 5, :With@ = 'Q(@char).Uppercased()')
? o1.Content()
#--> SOANZNZA

pf()
# Executed in 1.09
