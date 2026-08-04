# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #2.

load "../../stzBase.ring"
load "../_expect.ring"

pr()

aMyList = [
	:Mali  	 = [ 42, 18, 22 ],
	:Niger 	 = [ 87, 40, 18 ]
]

? IsHashList(aMyList)
#--> TRUE
Same(IsHashList(aMyList), TRUE)

? IsHashListOfNumbers(aMyList)
#--> TRUE
Same(IsHashListOfNumbers(aMyList), TRUE)

pf()
# Executed in almost 0 second(s) in Ring 1.22

#--------------------------------------------------#
#  Test Suite for stzVBarPlot (Vertical Bar Plot)  #
#--------------------------------------------------#
