# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #49.

load "../../stzBase.ring"

pr()

? StzLocaleQ([ :Country = :South_Africa, :Language = :tswana ]).CountryNativeName()
#--> iNingizimu Afrika

? StzLocaleQ([ :Country = :South_Africa, :Language = :tswana ]).LanguageNativeName()
#--> isiZulu

pf()
# Executed in 0.06 second(s) in Ring 1.23
