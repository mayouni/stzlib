# Narrative
# --------
# ? Stz(:Number, :Class)
#
# Extracted from stzGlobalTest.ring, block #36.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

#--> "stznumber"
# You can also say: ? StzNumberClass()

? @@(Stz(:Number, :Attributes))
#--> [ "@oobject", "@cVarName", "@cnumber" ]
# You can also say: ? StzNumberAttributes()

? Stz(:Number, :Methods)
#--> [ "init", "content", "initialcontent", "copy", ... ]
# You can also say: ? StzNumberMethods()

pf()
