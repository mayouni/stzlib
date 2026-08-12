# Narrative
# --------
# Label automatic normalization
#
# Extracted from stzgraphtest.ring, block #2.
#
# CHANGED 2026-08-12, and the reason is worth keeping because two documented
# behaviours disagreed with each other.
#
# This block used to record that a label's SPACES became underscores:
# "name of person" was stored as "name_of_person". Meanwhile
# doc/narrations/stzOrgChartDoc.md shows its rendered charts reading
# "VP Sales", "Sales Rep 1", "Board of Directors" -- with spaces. Both were
# committed, and only one can be true.
#
# The substitution was ID hygiene applied to DISPLAY TEXT. It was never
# needed even for the dot path: stzDiagram emits labels QUOTED
# (label="..."), so a space inside one has always been safe. What it did
# instead was change what the reader sees.
#
# So _NormalizeLabel now leaves spaces alone. The NEWLINE substitution
# stays, because an unescaped newline inside a quoted dot label breaks the
# statement it sits in -- that one is protecting the output, not editing it.
#
# An id is still an id: _IsWellFormedId still refuses a node id containing
# a space. Only the label is display text.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("")
oGraph {
	AddNodeXT("@name", "name of person")
	AddNodeXT("@age", "age of person")
	Connect("@name", "@age")

	? @@NL( Nodes() )
}
#--> The label is kept AS AUTHORED -- it is what the picture shows.
'
[
	[
		[ "id", "@name" ],
		[ "label", "name of person" ],
		[ "properties", [  ] ]
	],
	[
		[ "id", "@age" ],
		[ "label", "age of person" ],
		[ "properties", [  ] ]
	]
]
'

# A NEWLINE is still normalised, because that one protects the emitted dot
# rather than editing what the author wrote.
oNL = new stzGraph("nl")
oNL.AddNodeXT("@x", "two" + char(10) + "lines")
? @@( oNL.Nodes()[1][:label] )
#--> "two_lines"

# And an ID with a space is still refused: only the LABEL is display text.
try
	oBad = new stzGraph("bad")
	oBad.AddNode("has space")
	? "NOT REFUSED -- unexpected"
catch
	? "an id with a space is still refused"
done
#--> an id with a space is still refused

pf()
# Executed in almost 0 second(s) in Ring 1.27
