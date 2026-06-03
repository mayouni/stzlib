# Narrative
# --------
# ..........................................................
#
# Extracted from stzTtexttest.ring, block #17.

load "../../stzBase.ring"

pr()

str = StzStringQ('').FromURL("https://ring-lang.github.io/doc1.16/qt.html")

StzTextQ(str) {
	? Punctuations()
}

pf()
