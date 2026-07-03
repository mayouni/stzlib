# Narrative
# --------
#
# NOTE (audit, 2026-07-03): DEFERRED -- network-dependent demo (FromURL
# fetches a live web page); not assertable offline.
# pr()
#
# Extracted from stzStringTest.ring, block #597.

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
