# Narrative
# --------
# cText = "John is the son of John second.
#
# Extracted from stzTtexttest.ring, block #27.

load "../../stzBase.ring"

Second son of John second is William second."

StopWordsMustBeRemoved()

StzTextQ(cText) {
	? Words()
}
