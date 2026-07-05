# Narrative
# --------
#
# NOTE (audit, 2026-07-05): DEFERRED -- SpacifyXT multi-PHASE formatting (:AndThen separator/step/direction + :LastNChars) is only partially implemented -- the phase switch mid-string is not honored, so the grouped/decimal tail is wrong. Feature backlog (280-285 share this).
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #280.

load "../../stzBase.ring"

pr()

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
