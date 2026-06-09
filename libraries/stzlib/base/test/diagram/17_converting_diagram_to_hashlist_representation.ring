# Narrative
# --------
# Converting diagram to hashlist representation
#
# Extracted from stzdiagramtest.ring, block #17.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("HashlistExport")
oDiag.SetTheme(:pro)
oDiag.AddNodeXT("n1", "Node")

? @@NL( oDiag.ToHashlist() )
#--> [
# 	[ "id", "HashlistExport" ],
# 	[
# 		"nodes",
# 		[
# 			[
# 				[ "id", "n1" ],
# 				[ "label", "Node" ],
# 				[ "properties", [  ] ]
# 			]
# 		]
# 	],
# 	[ "edges", [  ] ],
# 	[ "properties", [  ] ],
# 	[ "theme", "pro" ],
# 	[ "layout", "topdown" ],
# 	[ "clusters", [  ] ],
# 	[ "annotations", [  ] ],
# 	[ "templates", [  ] ]
# ]


pf()
# Executed in 0.02 second(s) in Ring 1.25
