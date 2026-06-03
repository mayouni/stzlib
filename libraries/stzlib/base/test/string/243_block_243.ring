# Narrative
# --------
# #perf
#
# Extracted from stzStringTest.ring, block #243.

load "../../stzBase.ring"


StartProfiler()

oLargeStr = new stzString( UnicodeData() ) # Contains 1_897_793 chars
? oLargeStr.FindLast(";")
#--> 1897793

# Let's see the gains in performance between Ring 1.18 and Ring 1.22

? PerfGain100(12.99, 2.45) # Or simply PerfGain()
#--> 81.14%

? SpeedUpX(12.99, 2.45) # Or simply SpeedUp()
#--> 5.3X

StopProfiler()
# Executed in 2.45 second(s) in Ring 1.23
# Executed in 2.57 second(s) in Ring 1.22
# Executed in 5.63 second(s) in Ring 1.21
# Executed in 12.99 second(s) in Ring 1.18
