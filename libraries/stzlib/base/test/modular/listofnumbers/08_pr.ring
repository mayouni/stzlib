# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #8.

load "../../../stzBase.ring"


o1 = new stzPairOfNumbers([ 2.07, 0.39 ])

? o1.PerfGain100() 	# 100 ~> In percentage
#--> 81.16

? o1.SpeedUpX()		# X ~> In factor
#--> 5.31

pf()
#--> Executed in 0.02 second(s).
