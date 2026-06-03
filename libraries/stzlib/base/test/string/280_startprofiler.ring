# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #280.

load "../../stzBase.ring"


o1 = new stzString("9999999999999999")

o1.SpacifyXT(
	:Separator = [ " ", :AndThen = "." , :LastNChars = 7 ],
	:Step      = [ 3, :AndThen = 2 ],
	:Direction = [ :Backward, :AndThen = :Forward ]
)

? o1.Content()
#--> 999 999 999.99 99 99 9

pf()
# Executed in 0.03 second(s).
