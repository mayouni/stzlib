# Narrative
# --------
# StartProfiler()
#
# Extracted from stzObjectTest.ring, block #15.
#ERR panic: integer does not fit in destination type

load "../../stzBase.ring"

pr()

? Q("Ring").ToNumberW('{
	@number = len(@string)
}')
#--> 4

? Q("Ring").ToNumberXT('{
	@number = Q(@string).NumberOfCharsW("Q(@char).IsLowercase()")
}')
#--> 3

? Q("Ring").ToNumberXT('{
	@number = Q(@string).UnicodesQRT(:stzListOfNumbers).Sum()
}')
#--> 400

# In fact:
	? @@( Q("Ring").Unicodes() )
	#--> [ 82, 105, 110, 103 ]

	? Q("Ring").ToNumberXT('{
		@number += Q(@char).Unicode()
	}')
	#--> 400

StopProfiler()
#--> Executed in 0.30 seconds seconds.

pf()
