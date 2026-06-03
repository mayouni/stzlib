# Narrative
# --------
# Debugging external code execution
#
# Extracted from stzrcodetest.ring, block #1.

load "../../stzBase.ring"


pr()

R() {

	@('res = 2 + 3')
	Run()

	? Result()		#--> 5
	? Duration() + NL	#--> 0.30s

	? @@(Trace()) + NL
	#--> [
	# 	[
	# 	[ "language", "r" ],
	# 	[ "timestamp", "25/02/2025-09:08:58" ],
	# 	[ "duration", 0.30 ],
	# 	[ "log", "R script starting... Data written to file" ],
	# 	[ "exitcode", "" ],
	# 	[ "mode", "interpreted" ]
	# 	]
	# ]

	? Code()
	#--> The listing of the internal code generate by the class
	# in the target langauge (in this case R), including the code
	# we provided ('res = 2 + 3') and the code of the transformation
	# function transform_to_ring()

}

pf()
# Executed in 0.31 second(s) in Ring 1.22
