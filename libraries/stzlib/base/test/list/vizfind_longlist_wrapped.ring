# Narrative
# --------
# VizFind on a LONG list: the rendering wraps into fixed-width lines.
#
# When the rendered list is wider than the wrap width (default 50 columns),
# VizFind/VizFindXT/VizFindMany split it into successive lines and draw the
# marker row(s) beneath EACH line, with a blank line separating the wrapped
# blocks (none after the last). The "(count)" tally of an XT form is printed
# once, at the end of the final block. This keeps the visual readable for
# lists too wide for one line -- and it works for any string value, not just
# single chars.
#
# Authored example (not extracted) -- exercises the wrapping path of VizFind.

load "../../stzBase.ring"


/*---

pr()

StzListQ([ "A","B","A","C","A","D","E","A","B","F","A","C","A","G","A" ]) {
	? VizFindXT("A")
}
#--> [ "A", "B", "A", "C", "A", "D", "E", "A", "B", "F"
#    "A" :  --^---------^---------^--------------^-----------
#
#    , "A", "C", "A", "G", "A" ]
#    "A" : ---^---------^---------^--- (7)

pf()
# Executed in 0.01 second(s).

/*---
*/

pr()

SetVizWidth(80)
o1 = new stzList([ "A","B","A",[ "A", "B" ], "C","A","D","E", [ "A", "B" ], "A","B" ])
? o1.VizFindXT(["A", "B"])

pf()
