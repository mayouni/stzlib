# Narrative
# --------
# StzTextQ("mahmoud, ahmed, mohamed, Mahmoud, mahmoud, ahmed.") {
#
# Extracted from stzTtexttest.ring, block #25.

load "../../stzBase.ring"

pr()

	ReplaceWordsWithMarquersXT([
		:By = :OrderOfOccurrenceOfWords,
		:Except = [],
		:StopWords = :MustNotBeRemoved
	])
	#--> "#1, #2, #3, #4, #5, #6."
}

pf()
