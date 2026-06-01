# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #284.

load "../../../stzBase.ring"


o1 = new stzString("999999999999")

o1.SpacifyXT(
	:Using     = [ " ", "." ],
	:Step      = [ 3, 	  :AndThen = 2, :LastNChars = 5	],
	:Direction = [ :Backward, :AndThen = 'forward' ]
)

? o1.Content()
#--> 9 999 999.99 99 9

pf()
# Executed in 0.03 second(s).
