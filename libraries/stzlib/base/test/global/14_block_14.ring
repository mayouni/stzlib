# Narrative
# --------
# #perf
#
# Extracted from stzGlobalTest.ring, block #14.

load "../../stzBase.ring"


pr()

# The ForEach alternative, by Softanza, solves the For/in
# weakness and performs the same loop in a second!

@ForEach( :number, :in = 1 : 500_000 ) {
	// Do nothing
}

pf()
# Executed in 1.25 second(s) in Ring 1.21
# Executed in 2.04 second(s) in Ring 1.18

# But ForEach offers more flexibility...
