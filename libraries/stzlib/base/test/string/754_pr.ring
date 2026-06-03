# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #754.

load "../../stzBase.ring"


# You can box the entire string like this:
? StzStringQ("SOFTANZA").BoxedXT([])
#-->
# ┌──────────┐
# │ SOFTANZA │
# └──────────┘

# Or box it char by char like this:

? StzStringQ("SOFTANZA").BoxedXT([ :EachChar = TRUE ])

#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

pf()
# Executed in 0.04 second(s) in Ring 1.23
