# Narrative
# --------
# #narration #perf CONCATENATING STRINGS IN RING AND SOFTANZA
#
# Extracted from stzStringTest.ring, block #976.

load "../../../stzBase.ring"

StartProfiler()

# In Ring, concatenating 1 million strings takes about 45 seconds:
#~> (The code setion is commented,  because it takes a lot of time)

#	str = ""
#	for i = 1 to 1_000_000
#		str += "السّلام عليكم ورحمة الله"
#	next
#	? "Finished"
#
#	? ElapsedTime() + NL
#	# Executed in 44.94 second(s) in Ring 1.22

# While in Softanza, using  Concatenate(), this take about 4 seconds:

	ResetTimer()

	acList = []
	for i = 1 to 1_000_000
		acList + "السّلام عليكم ورحمة الله"
	next
	
	Concatenate(acList)
	#--> Executed in 3.64 second(s) in Ring 1.22

	? ElapsedTime()

# Which is a speed factor of about 11 times!

	? SpeedX(45, 4)
	#--> 11.25

StopProfiler()
# Executed in 3.83 second(s) in Ring 1.22
