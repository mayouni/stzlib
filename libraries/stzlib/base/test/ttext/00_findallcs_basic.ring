# Narrative
# --------
# FindAllCS on stzText: first sanity-check that the legacy
# stzText basics still work before getting into the more involved
# Chars()/Letters() blocks that follow.
#
# Extracted from stzTtexttest.ring, block #0 (the head block that
# the original extraction pass skipped).

load "../../stzBase.ring"


profon()

o1 = new stzText("ring programming, best of programming!")
? o1.FindAllCS("programming", 0)
#--> [ 6, 27 ]

proff()
