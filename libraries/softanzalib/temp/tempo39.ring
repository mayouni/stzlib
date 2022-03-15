load "stzlib.ring"

aList = [
		:en = "house",
		:fr = "maison",
		:ar = "منزل"
	]

o1 = new stzList(aList)
? o1.IsMultingualString()
