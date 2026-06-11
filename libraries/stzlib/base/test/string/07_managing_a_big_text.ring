# Narrative
# --------
# #perf managing a big text
#
# Extracted from stzStringTest.ring, block #7.

load "../../stzBase.ring"


pr()

cBigText = read("../_data/bigtext.txt")

oBig = new stzString(cBigText)

? oBig.NumberOfChars()
#--> 6617121

? oBig.NumberOfLines() + NL
#--> 128457

? oBig.SizeInBytes() + NL
#--> 6617121

? oBig.FindCS("madrid", FALSE)
#--> [
#	1538708
#	1543968
#	1544385
#	1546342
#	1550119
#	5270717
#	5621458
#	6590675
# ]

oBig.ReplaceCS("madrid", "vienna", FALSE)

pf()
# Executed in 1.54 second(s) in Ring 1.26 (Powered by StzEngine)
# Executed in 5.21 second(s) in Ring 1.22
