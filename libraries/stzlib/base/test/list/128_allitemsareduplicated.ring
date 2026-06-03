# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #128.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

	alist = []
	for i = 1 to 30000
		alist + 'A' + 'B'
	next
	alist + "A" + "A" + 2 + "B" + "B" + 2 + "B"

	o1 = new stzList(alist)
	
	? o1.AllItemsAreDuplicated()
	#--> TRUE

pf()
# Executed in 1.64 second(s) in Ring 1.22
# Executed in 1.82 second(s) in Ring 1.21
# Executed in 4.75 second(s) in Ring 1.19
