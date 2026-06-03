# Narrative
# --------
# ..........................................................
#
# Extracted from stzTtexttest.ring, block #17.
#ERR Error (R14) : Calling Method without definition: fromurl

load "../../stzBase.ring"

pr()

str = StzStringQ('').FromURL("https://ring-lang.github.io/doc1.16/qt.html")

StzTextQ(str) {
	? Punctuations()
}

pf()
