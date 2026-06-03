# Narrative
# --------
# pr()
#
# Extracted from stzjsontest.ring, block #3.

load "../../stzBase.ring"

pr()

aNonJsonList = [
	:a = 10,
	:b = 20,
	[
		:d = 30,
		:e = 40
	]
]

? IsJsonList(aNonJsonList)
#--> FALSE

? ListToJson(aNonJsonList)
#--> Incorrect param type! aList must be a well-formatted JSON list.

pf()
