# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #389.
#ERR Error (R14) : Calling Method without definition: isstzclassname

load "../../stzBase.ring"

pr()

? StzStringQ(:stzList).IsStzClassName()
#--> TRUE

? StzListQ( :ReturnedAs = :stzList ).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
