# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #386.
#ERR Error (R3) : Calling Function without definition: @@sp

load "../../stzBase.ring"

pr()

aList = [
	:Arabic,
	:Arabic,
	:French,
	:English,
	:Spanish,
	:Spanish,
	:English,
	:Arabic
]

StzListQ(aList) {

 	? @@SP( Classify() ) + NL
	#--> [
	# 	:Arabic  = [ 1, 2, 8 ],
	# 	:French  = [ 3 ],
	# 	:Enslish = [ 4, 7 ],
	#    	:Spanish = [ 5, 6 ]
	#    ]

	? Classes()
	#--> [ :Arabic, :French, :English, :Spanish ]

	? NumberOfClasses()
	#--> 4
}

pf()
# Executed in 0.02 second(s).
