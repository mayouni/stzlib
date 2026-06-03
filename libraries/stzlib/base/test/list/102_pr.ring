# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #102.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

# In this example, the large list contains +160K items...

	aLargeList = ["_", "_", "♥"]
	for i = 1 to 100_000
		aLargeList + "_"
	next
	
	aLargeList + "♥" + "_" + "_" + "♥"
	
	for i = 1 to 50_000
		aLargeList + "_"
	next i
	
	aLargeList + "♥" + "_" + "_" + "♥"
	

	# ElapseTime: 0.08s

	o1 = new stzList(aLargeList)

	# ElapsedTime: 0.11

	o1.StringifyAndReplace("♥", :With = "*")

	# ElapsedTime: 12.83s

	o1.LastNItems(40_000)
	#--> [ "*", "_", "_", "*" ]

pf()
# Executed in  4.09 second(s) in Ring 1.19 (64 bits)
# Executed in  4.53 second(s) in Ring 1.19 (32 bits)
# Executed in  7.40 second(s) in Ring 1.18
# Executed in 16.62 second(s) in Ring 1.17
