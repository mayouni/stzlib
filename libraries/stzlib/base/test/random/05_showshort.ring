# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #5.

load "../../stzBase.ring"

pr()

nTestSeed = 12345
anUserIds = []

for i = 1 to 1000
    anUserIds + ARandomNumberXT(nTestSeed + i)
next

? ShowShort( anUserIds )
#--> [ 7587, 7590, 7593, "...", 10843, 10846, 10849 ]

pf()
# Executed in almost 0 second(s) in Ring 1.23
