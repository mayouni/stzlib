# Narrative
# --------
# Two introspection predicates that Softanza uses to validate identifiers.
#
# IsStzClassName() asks whether a string names a real Softanza class:
# StzStringQ(:stzList).IsStzClassName() is TRUE because "stzList" is a
# known class. IsOneOfTheseNamedParams() is the guard Softanza methods
# use to accept flexible keyword arguments: given a named param like
# :ReturnedAs = :stzList, it confirms the supplied key belongs to an
# accepted alias set [ :ReturnedAs, :ReturnAs ], so callers can spell
# the option either way. Both return TRUE here.
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
