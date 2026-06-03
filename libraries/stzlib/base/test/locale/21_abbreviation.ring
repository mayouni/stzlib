# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #21.

load "../../stzBase.ring"

pr()

# All these return the abbreviation ru_RU

? StzLocaleQ([ :Language = :Russian, :Script = :Latin, :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian ]).Abbreviation()
? StzLocaleQ([ :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian, :Script = :Latin ]).Abbreviation()
? StzLocaleQ([ :Language = :Russian, :Country = :Russia ]).Abbreviation()
? StzLocaleQ([ :Script = :Latin, :Country = :Russia ]).Abbreviation()

#--> ru_RU

pf()
# Executed in 0.09 second(s) in Ring 1.23
