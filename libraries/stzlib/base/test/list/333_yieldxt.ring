# Narrative
# --------
# YieldXT: yield the items inside a positional or conditional window.
#
# The yielder "@item" (alias "@char" for char lists) returns the value at
# each visited position; named options define the window:
#   * :FromPosition = a, :To = b  -- positions a..b inclusive (b may be
#       negative, counting from the end: -3 is the 3rd-from-last).
#   * :StartingAt = a, :Until = c -- from a onward, stop BEFORE the first
#       item satisfying the W-condition c.
#   * :StartingAt = a, :UntilXT = c -- same, but INCLUDE that stop item
#       (the eXtended until).
#
# Extracted from stzlisttest.ring, block #333.

load "../../stzBase.ring"

pr()

o1 = new stzList([ ".", ".", "3", "4", ".", ".", "7", "8", "9", ".", "." ])

? o1.YieldXT( '@item', :FromPosition = 4, :To = -3 )
#--> [ "4", ".", ".", "7", "8", "9" ]

? o1.YieldXT( '@char', :StartingAt = 3, :Until = ' @item = "." ' )
#--> [ "3", "4" ]

? o1.YieldXT( '@char', :StartingAt = 3, :UntilXT = ' @item = "." ' )
#--> [ "3", "4", "." ]

pf()
# Executed in 0.02 second(s).
