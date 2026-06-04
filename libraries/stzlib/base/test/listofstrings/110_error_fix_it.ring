# Narrative
# --------
# ERROR: Fix it!
#
# Extracted from stzlistofstringstest.ring, block #110.
#ERR Error (R14) : Calling Method without definition: boxxt

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "CAIRO", "TUNIS", "PARIS" ])

? o1.BoxXT([ :AllCorners = :Round, :EachChar = TRUE ])
/*
? o1.BoxedXT([ :AllCorners = :Round, :EachChar = FALSE, :Width = 10, :TextAdjustedTo = :Right ])
? o1.VizFindBoxed("I")

? o1.boxedXT([ :line = :dashed,
		:corners = [ :round, :rectangular, :round, :round ]
	    ])


/* ---------------------

o1 = new stzListOfStrings([ "bingo", "tongo", "congo" ])
o1.ReplaceStringAtPosition(3,"fongo")
? @@( o1.Content() )
#--> [ "bingo", "tongo", "fongo" ]

pf()
