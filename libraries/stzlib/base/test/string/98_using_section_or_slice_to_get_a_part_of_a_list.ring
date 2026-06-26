# Narrative
# --------
# # Using Section() (or Slice()) to get a part of a list
#
# Extracted from stzStringTest.ring, block #98.
#
# DEFECT (deferred -- see _AUDIT_DEFECTS.md): both forms here are broken --
# Q(1:20).Section(:FromPosition = 4, :To = :LastItem) raises "Incorrect params!
# n1 and n2 must be numbers" (the named-param / :LastItem symbol form is not
# resolved), and Slice() does not exist (R14). The plain positional Section(a,b)
# works (see block #46/#49). Left in print form; NOT asserted.

load "../../stzBase.ring"

pr()

aList = 1:20

# Verbose form (currently raises):
? ShowShort( Q(aList).Section(:FromPosition = 4, :To = :LastItem) )
#--> expected [ 4, 5, 6, "...", 18, 19, 20 ]

# Short form (Slice currently undefined):
? ShowShort( Q(1:20).Slice(4, :Last) )
#--> expected [ 4, 5, 6, "...", 18, 19, 20 ]

pf()
