# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #549.

load "../../stzBase.ring"


oTrueObj = TRUEObject()
oFalseObj = FALSEObject()

o1 = new stzList([
	"_", 3, "_" , oTrueObj, 6, "*",
	[ "L1", "L1" ], 12, oFalseObj,
	[ "L2", "L2" ], 25, "*"
])

? o1.FindWhereXT('{
	( NOT isObject(@item) ) and
	( isString(@NextItem) and @NextItem = "*" )
}')
#--> [ 5, 11]

? o1.FindWhereXT('{
	isNumber(@item) AND
	@i <= This.NumberOfItems() - 3 AND

	isNumber(This[@i+3]) AND
	This[@i+3] = DoubleOf(@item)	
}')
#--> [ 2, 5 ]

? o1.FindWhereXT('{
	isNumber(@item) AND
	@i <= This.NumberOfItems() - 3 AND

	isNumber(This[@i+3]) AND
	This[@i+3] != DoubleOf(@item)	
}')
	#--> [ 8 ]

pf()
# Executed in 0.35 second(s).
