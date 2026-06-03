# Narrative
# --------
# // ReplaceWord --> ReplaceWords --> ReplaceWordsWithMarquers --> ReplaceWordsWithMarquersXT
#
# Extracted from stzTtexttest.ring, block #24.
#ERR Error (R3) : Calling Function without definition: replacewordswithmarquers

load "../../stzBase.ring"

pr()

// --> ReplaceWordCS
StzTextQ("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
	ReplaceWordsWithMarquers()
	//ReplaceWordsCS(["mahmoud"], :With = ["Mansour"], 0)
	//? Content()
}

pf()
