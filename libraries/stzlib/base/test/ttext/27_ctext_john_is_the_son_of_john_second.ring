# Narrative
# --------
# cText = "John is the son of John second.
#
# Extracted from stzTtexttest.ring, block #27.
#ERR exit 1: Error (S1) In file: 27_ctext_john_is_the_son_of_john_second.ring

load "../../stzBase.ring"

pr()

Second son of John second is William second."

StopWordsMustBeRemoved()

StzTextQ(cText) {
	? Words()
}

pf()
