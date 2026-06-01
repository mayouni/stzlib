# Narrative
# --------
# REMOVING AROUND
#
# Extracted from stzStringTest.ring, block #882.

load "../../../stzBase.ring"


StartProfiler()
	
Q("_-♥-_-♥-_-♥-_") {
	
	RemoveXT("-", :AroundEach = "♥") # Or simply :Around
	? Content()
	#--> _♥_♥_♥_
}
	
StopProfiler()
# Executed in 0.06 second(s)
