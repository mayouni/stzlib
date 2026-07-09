# Narrative
# --------
# ExecutableSection: the safe index window for relative-offset conditional code.
#
# When conditional code reads or writes neighbouring items via @i offsets, such
# as { This[@i - 3] = This[@i + 3] }, it cannot run at every position without
# stepping out of bounds. StzCCodeQ(...).ExecutableSection() parses the signed
# @i offsets and returns the [start, end] band over which the rule is safe: with
# a +3 look-ahead and a -3 look-behind it yields [ 4, -3 ] -- start at item 4,
# stop 3 items before the end (the -3 is the end-relative anchor).
#
# Extracted from stzlisttest.ring, block #482.

load "../../stzBase.ring"

pr()

? StzCCodeQ('{ This[@i - 3 ] = This[ @i + 3 ] }').ExecutableSection()
#--> [4, -3]

pf()
# Executed in 0.01 second(s) in Ring 1.27
# Executed in 0.07 second(s) in Ring 1.22
