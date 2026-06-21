# Narrative
# --------
# IsLocaleList(): does this hashlist describe a LOCALE?
#
# A locale list is a hashlist with up to three keys -- :Language, :Country,
# :Script -- whose values are valid locale identifiers (name, abbreviation
# or number). At least one must be present. Values may be spelled in full
# ("arabic") or abbreviated ("ar", "TN"), and the keys are matched case-
# insensitively (:script works too). The single-string special locales
# (:Default, :System, "C", ...) also qualify.
#
# Extracted from stzlisttest.ring, block #627.

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
# Executed in almost 0 second(s)
