# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #2.

load "../../stzBase.ring"


aMyList = [
	:Mali  	 = [ 42, 18, 22 ],
	:Niger 	 = [ 87, 40, 18 ]
]

? IsHashList(aMyList)
#--> TRUE

? IsHashListOfNumbers(aMyList)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

#--------------------------------------------------#
#  Test Suite for stzVBarPlot (Vertical Bar Plot)  #
#--------------------------------------------------#
