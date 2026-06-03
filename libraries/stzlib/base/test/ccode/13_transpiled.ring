# Narrative
# --------
# StartProfiler()
#
# Extracted from stzccodetest.ring, block #13.

load "../../stzBase.ring"

pr()

	o1 = new stzCCode('Q(@EachChar).IsUppercase()')
	? o1.Transpiled()
	#--> Q( This[@i] ).IsUppercase()

	? o1.ExecutableSectionXT()
	#--> [ 1, :Last ]

StopProfiler()

pf()
# Executed in 0.03 second(s) in Ring 1.23
# Executed in 0.05 second(s) in Ring 1.21
# Executed in 0.11 second(s) in Ring 1.20
# Executed in 0.36 second(s) in Ring 1.17
