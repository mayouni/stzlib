# Narrative
# --------
# VizFind: a quick VISUAL map of where a value occurs in the list.
#
# It renders the list as code and draws a "^"/"-" marker line just
# underneath, so the eye lands straight on the matches -- handy when
# scanning a list at the REPL.
#
# Works on lists of chars (the markers align to single columns);
# generalising to longer strings / other types is a TODO.
#
# Extracted from stzlisttest.ring, block #435. (The original recorded
# output was copied from a different example; corrected below to the
# real output of this list.)

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFind("A")
}
#--> [ "A", "B", "A", "C", "A", "D", "A" ]
#     --^---------^---------^---------^---

pf()
# Executed in 0.01 second(s).
