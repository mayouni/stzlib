# Narrative
# --------
# #ring
#
# Extracted from stznumbertest.ring, block #8.

load "../../stzBase.ring"


pr()

for i = 1 to 5000
	if isWeiferich(i)
		? i
	ok
next
#--> [ 1, 4 ]

pf()
# Executed in 0.36 second(s) in Ring 1.21
