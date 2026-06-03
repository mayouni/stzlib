# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #38.

load "../../stzBase.ring"

pr()

o1 = new stzLocale([ :Language = :Spanish, :Country = :Spain ])
? o1.Abbreviation()	#--> es_ES

pf()
# Executed in 0.02 second(s) in Ring 1.23
