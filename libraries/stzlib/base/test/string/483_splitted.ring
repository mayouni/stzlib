# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #483.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? Q(".;1;.;.;." ) / ";" # Same as: ? Q(".;1;.;.;." ).Splitted(:Using = ";")

#--> [ ".", "1", ".", ".", "." ]

pf()
# Executed in 0.01 second(s).
