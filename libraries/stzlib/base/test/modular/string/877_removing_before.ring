# Narrative
# --------
# REMOVING BEFORE
#
# Extracted from stzStringTest.ring, block #877.

load "../../../stzBase.ring"


StartProfiler()
	
Q("Ring ***programming language.") {
	
	RemoveXT("***", :Before = "programming")
	? Content()
	#--> Ring programming language.
	
}
	
StopProfiler()
#--> Executed in 0.04 second(s)
