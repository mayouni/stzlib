# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #389.

load "../../stzBase.ring"

pr()

? StzStringQ(:stzList).IsStzClassName()
#--> TRUE

? StzListQ( :ReturnedAs = :stzList ).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
