# Narrative
# --------
# #perf #ring #unicode
#
# Extracted from stzStringTest.ring, block #977.
#ERR Error (R24) : Using uninitialized variable: _time0

load "../../stzBase.ring"


pr()

# Ring can add 1 million strings to a list quickly:

	acList = []
	for i = 1 to 1_000_000
		acList + "any text"
	next

	? ElapsedTime()
	#--> 0.26 second(s)

# But when the string is unicode (arabic in this case),
# this becomes visibly less performant

	ResetTimer()

	acList = []
	for i = 1 to 1_000_000
		acList + "السّلام عليكم ورحمة الله"
	next

	? ElapsedTime()
	#--> 0.47 second(s)

pf()
# 0.47 second(s)
