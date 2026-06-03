# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #918.
#ERR Error (R14) : Calling Method without definition: replacesubstringatpositionsbymany

load "../../stzBase.ring"

pr()

o1 = new stzString("--[...]---[...]---[...]---[~~~]--[~~~]--")
o1.ReplaceSubStringAtPositionsByMany([ 27, 34], "[~~~]", [ "bbb", "aaa" ])

? o1.Content()
#--> --[...]---[...]---[...]---bbb--aaa--

pf()
# Executed in 0.07 second(s).
