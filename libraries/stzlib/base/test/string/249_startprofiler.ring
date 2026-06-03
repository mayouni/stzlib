# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #249.

load "../../stzBase.ring"


? Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").Lowercased()
#--> i believe in ring future and engage for it!

? Q("i believe in ring future and engage for it!").IsLowercase()
#--> TRUE

# As a side note, the last fuction used above (IsLowercase()) is
# misspelled (should be IsLowerCase() with an "r" after low),*
# but Softanza accepts it.

StopProfiler()
# Executed in 0.05 second(s) in Ring 1.21
