# Narrative
# --------
# Copy() makes an INDEPENDENT list -- mutating the copy never touches the
# original.
#
# A foundational value-semantics guarantee: o2 = o1.Copy() yields a fresh
# stzList, so AddItem on o2 leaves o1 exactly as it was. (Ring lists are
# reference-shared, so Copy() is what gives you a safe, detached duplicate.)
#
# Extracted from stzlisttest.ring, block #1.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "Ali", "Hedi" ])

o2 = o1.Copy()
o2.AddItem("Said")
? @@(o2.Content())
#--> [ "Ali", "Hedi", "Said" ]

? @@( o1.Content() ) # The original list is unchanged
#--> [ "Ali", "Hedi" ]

pf()
# Executed in almost 0 second(s)
