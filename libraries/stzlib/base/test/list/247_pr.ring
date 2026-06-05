# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #247.

load "../../stzBase.ring"

pr()

o1 = new stzList(
	[] +
	"EMM, ahh," +		#--> "emm* ahh*"	<<< [1]
	"emm, ahh*" +		#--> "emm* ahh*"	<<< [2]

	"emm* AHH*" +		#--> "__emm* ahh*__"	!!!! [3]

	1:3 +			#--> "[1* 2* 3*]"
	10 +
	100 +
	1:3 +			#--> "[1* 2* 3*]"
	1000 +

	"oh, bah,," +		#--> "oh* bah**"	<<< [9]

	"[ 1* 2* 3 ]"		#--> "__[ 1* 2* 3 ]__"	!!!! [10]
)

o1.StringifyLowercaseAndReplaceXT(",", "*")
o1.Show()

#--> [
#	[
#		"emm* ahh*",
#		"emm* ahh*",
#		"__emm* ahh*__",
#		"[ 1* 2* 3 ]",
#		"10", "100",
#		"[ 1* 2* 3 ]",
#		"1000",
#		"oh* bah**",
#		"__[ 1* 2* 3 ]__"
#	],
#
#	[ 1, 2, 9 ], #--> Items where "," is replaced by "*" 
#	[ 3, 10 ]    #--> Items containing "*" but no "," 
# ]

pf()
# Executed in 0.01 second(s)
