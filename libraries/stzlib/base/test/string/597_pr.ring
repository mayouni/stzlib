# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #597.
#ERR Error (R3) : Calling Function without definition: fromurl

load "../../stzBase.ring"

pr()

StzStringQ('') {

	FromURL("https://ring-lang.github.io/doc1.16/qt.html")
	Show()

}
#--> Shows the page content as Text/HTML

pf()
# Executed in 0.46 second(s) in Ring 1.22
# Executed in 2.63 second(s) in Ring 1.18
