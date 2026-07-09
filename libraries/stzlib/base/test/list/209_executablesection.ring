# Narrative
# --------
# Asks an StzCCode (Softanza conditional-code) object where its
# executable part lives inside the raw expression string.
#
# StzCCodeQ() wraps a W-style predicate written as code text, here
# 'NOT isNumber( This[@i + 1] )'. ExecutableSection() returns the
# position bounds of the runnable expression as a two-number list.
# The reported [1, -1] is the Softanza convention for "from the
# first character to the last" -- i.e. the whole string is the
# executable section, with -1 standing in for the end position.
# This lets the conditional-code engine know which span to evaluate.
#
# Extracted from stzlisttest.ring, block #209.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Asks an StzCCode (Softanza conditional-code) object where its executable part lives inside")

	Then("executablesection example 1", @@( StzCCodeQ('NOT isNumber( This[@i + 1] )').ExecutableSection() ), @@( [1, -1] ))
EndScenario()

Summary()
