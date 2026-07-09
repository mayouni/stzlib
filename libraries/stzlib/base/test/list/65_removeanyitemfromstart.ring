# Narrative
# --------
# RemoveAnyItemFromStart / RemoveAnyItemFromEnd: peel the whole LEADING or
# TRAILING run of a given item.
#
# The list-level counterpart of the string trims: RemoveAnyItemFromStart
# drops the two leading "🔻" (a 4-byte emoji, handled whole, never split),
# leaving the inner "🔻" pair untouched; RemoveAnyItemFromEnd then peels the
# trailing run, leaving [ "1","2","3" ]. Only contiguous edge runs go.
#
# Extracted from stzlisttest.ring, block #65.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "🔻", "🔻", "1", "2", "3", "🔻", "🔻" ])
o1.RemoveAnyItemFromStart("🔻")
? @@( o1.Content() )
#--> [ "1", "2", "3", "🔻", "🔻" ]

o1.RemoveAnyItemFromEnd("🔻")
? @@( o1.Content() )
#--> [ "1", "2", "3" ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.01 second(s) before
