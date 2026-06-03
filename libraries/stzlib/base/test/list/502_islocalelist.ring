# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #502.

load "../../stzBase.ring"

pr()

# All these return TRUE

? IsLocaleList([ :DefaultLocale ])
#--> TRUE

? IsLocaleList([ :SystemLocale ])
#--> TRUE

? IsLocaleList([ :CLocale ])
#--> TRUE

? IsLocaleList([ :Language = :Arabic, :Script = :Arabic, :Country = :Tunisia ])
#--> TRUE

? IsLocaleList([ :Language = :Arabic, :Country = :Tunisia ])
#--> TRUE

? IsLocaleList([ :Country = :Tunisia ])
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.22
