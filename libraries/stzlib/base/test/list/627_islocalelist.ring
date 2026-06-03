# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #627.
#ERR Error (R14) : Calling Method without definition: islocalelist

load "../../stzBase.ring"

pr()

o1 = new stzList([ :Language = "arabic", :Country = "tn", :Script = "arabic" ])

? o1.IsLocaleList() + NL
#--> TRUE

o1 = new stzList([ :Language = "ar", :Country = "TN", :script = "arabic" ])
? o1.IsLocaleList() + NL
#--> TRUE

? StringIsScriptName("latin")
#--> TRUE

pf()
# Executed in 0.03 second(s).
