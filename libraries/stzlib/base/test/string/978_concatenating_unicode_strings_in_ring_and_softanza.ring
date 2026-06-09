# Narrative
# --------
# #narration #perf #ring CONCATENATING UNICODE STRINGS IN RING AND SOFTANZA
#
# Extracted from stzStringTest.ring, block #978.

load "../../stzBase.ring"

pr()

# Ring can concatenate 1 million latin strings in almost 2 seconds:

	cStr = ""
	for i = 1 to 1_000_000
		cStr += "any text"
	next

	? ElapsedTime()
	#--> 1.70 second(s)

# But when the string is in unicode (arabic in this case), Ring's
# performance degradates to more then 45 seconds:
#~> (The code setion is commented,  because it takes a lot of time)

#	ResetTimer()
#
#	cStr = ""
#	for i = 1 to 1_000_000
#		cStr += "السّلام عليكم ورحمة الله"
#	next
#
#	? ElapsedTime() + NL
#	#--> 45.63 second(s)

# Hopefully, Softanza has the Concatenate() function that
# does the job in less then 4 seconds:

	ResetTimer()

	aListOfStr = []

	for i = 1 to 1_000_000
		aListOfStr + "السّلام عليكم ورحمة الله"
	next
	# The filling takes 1.70 seconds

	str = Concat(aListOfStr)

	? ElapsedTime() + NL
	# 3.66 second(s)

# Which is a performance gain of +88%

	? PerfGain100(45.63, 3.66)
	#--> 91.98

# or a speed factor of +8 times!

	? SpeedFactor(45.63, 3.66)
	#--> 12.47

pf()
# Executed in 5.33 second(s) in Ring 1.22
