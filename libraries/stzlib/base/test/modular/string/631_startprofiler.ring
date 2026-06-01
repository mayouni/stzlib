# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #631.

load "../../../stzBase.ring"


	acMyKids = [ "Teeba", "Haneen", "Hussein" ]
	
	o1 = new stzString("My three kids are #1, #2 and #3!")

	? @@( o1.MarquersZZ() )
	#--> [ [ "#1", [ 19, 20 ] ], [ "#2", [ 23, 24 ] ], [ "#3", [ 30, 31 ] ] ]

	o1.ReplaceMarquers(:with = acMyKids)
	? o1.Content() + NL
	#--> My three kids are Teeba, Haneen and Hussein!
	
	o1.ReplaceSubStringsWithMarquers(acMyKids)
	? o1.Content() + NL
	#--> My three kids are #1, #2 and #3!
	
	o1.SortMarquersInDescending()
	? o1.Content() + NL
	#--> My three kids are #3, #2 and #1!
	
	o1.ReplaceMarquers(:With = acMyKids)
	? o1.Content()
	#--> My three kids are Hussein, Haneen and Teeba!

StopProfiler()
# Executed in 0.03 second(s) in Ring 1.22
# Executed in 0.06 second(s) in Ring 1.21
# Executed in 1.73 second(s) in Ring 1.18
# Executed in 2.90 second(s) in Ring 1.17
