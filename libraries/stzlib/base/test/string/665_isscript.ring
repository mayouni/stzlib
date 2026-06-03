# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #665.

load "../../stzBase.ring"

pr()

? StzStringQ(:Arabic).IsScript()
#--> TRUE

? StzStringQ(:Arabic).IsScriptName()
#--> TRUE

? StzStringQ(:Arab).IsScriptAbbreviation()
#--> TRUE

? StzStringQ("1").IsScriptCode()
#--> TRUE

pf()
# Executed in 0.01 second(s).
