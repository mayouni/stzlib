# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #7.

load "../../../stzBase.ring"


o1 = new stzListOfNumbers([ 2.07, 0.39, 0.12])

? o1.PerfGain100() 	# 100 ~> In percentage
#--> [ 81.16, 69.23 ])

? o1.SpeedUpX()		# X ~> In factor
#--> [ 5.31, 3.25 ]

pf()
#--> Executed in 0.02 second(s).
