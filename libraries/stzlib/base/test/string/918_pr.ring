# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #918.

load "../../stzBase.ring"


o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
o1.ReplaceSubStringAtPositionsByMany([ 27, 34], "[~~~]", [ "bbb", "aaa" ])

? o1.Content()
#--> --[...]---[...]---[...]---bbb--aaa--

pf()
# Executed in 0.07 second(s).
