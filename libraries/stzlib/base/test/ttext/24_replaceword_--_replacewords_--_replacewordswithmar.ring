# Narrative
# --------
# // ReplaceWord --> ReplaceWords --> ReplaceWordsWithMarquers --> ReplaceWordsWithMarquersXT
#
# Extracted from stzTtexttest.ring, block #24.

load "../../stzBase.ring"

// --> ReplaceWordCS
StzTextQ("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
	ReplaceWordsWithMarquers()
	//ReplaceWordsCS(["mahmoud"], :With = ["Mansour"], 0)
	//? Content()
}
