# Narrative
# --------
# pr()
#
# Extracted from stzPlotTest.ring, block #3.

load "../../stzBase.ring"

pr()

aMyList = [
	:Mali  	 = [ :2020 = 42, :2022 = 18, :2024 = 22 ],
	:Niger 	 = [ :2020 = 87, :2022 = 40, :2024 = 18 ]
]

? IsHashList(aMyList)
#--> TRUE

? IsHashListOfLists(aMyList)
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22
