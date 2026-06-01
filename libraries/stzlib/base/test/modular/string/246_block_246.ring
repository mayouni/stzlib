# Narrative
# --------
# #perf
#
# Extracted from stzStringTest.ring, block #246.

load "../../../stzBase.ring"


StartProfiler()

#                    2    7
o1 = new stzString("•♥••••♥••")

? o1.FindNthW(2, '@char = "♥"')
#--> 7
# Executed in 0.13 second(s)

? o1.FindNthW(2, '@substring = "•♥•"')
#--> 6

StopProfiler()
#--> Executed in 0.25 second(s) in Ring 1.21
*/
