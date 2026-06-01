# Narrative
# --------
# # Using Section() (or Slice()) to get a part of a list
#
# Extracted from stzStringTest.ring, block #98.

load "../../../stzBase.ring"


aList = 1:20

# Verbose form:
? ShowShort( Q(aList).Section(:FromPosition = 4, :To = :LastItem) )
#--> [ 4, 5, 6, "...", 18, 19, 20 ]

# Short form:
? ShowShort( Q(1:20).Slice(4, :Last) )
#--> [ 4, 5, 6, "...", 18, 19, 20 ]
